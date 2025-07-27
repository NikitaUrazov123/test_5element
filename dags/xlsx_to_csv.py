from airflow.decorators import task, dag
from datetime import datetime

"""
1.Получает первый xlsx файл из smb шары по указаному пути
2.Указанные листы в конфиге преобразовывает в csv и сохраняет по второму пути шары
3.Таскфлоу стиль + @task.virtualenv используется для изоляции выполнения и использует временное окружение 
"""

CONFIG = {
    "SMB_SERVER": "192.168.0.105", # Парамеры шары и пути должны быть заданеы через переменные airflow
    "SMB_SHARE": "share",
    "SMB_INPUT_PATH": "/test_5element/xlsx_input",
    "SMB_OUTPUT_PATH": "/test_5element/csv_output",
    "SHEETS_TO_CONVERT": [
        "Отзывы на товары",
        "Отзывы на магазины",
        "Из внешних источников",
        "Опросы",
        "Другое"
    ],
    "SMB_USER": "elem5",
    "SMB_PASSWORD": "elem5"
}

@dag(
    schedule=None,
    start_date=datetime(2025, 7, 1),
    catchup=False
)
def xlsx_to_csv():

    @task.virtualenv(
        requirements=[
            "numpy==1.26.4",
            "pandas==2.1.4",
            "openpyxl==3.1.2",
            "smbprotocol==1.10.1"
            ],

        system_site_packages=False
    )
    def process_xlsx_task(config: dict):
        import pandas as pd
        from smbclient import register_session, open_file, scandir
        from io import BytesIO, StringIO
        import logging

        logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
        logger = logging.getLogger("xlsx_to_csv")

        result = {
            "processed_file": None,
            "converted_sheets": [],
            "error": None
        }

        try:
            register_session(
                server=config["SMB_SERVER"],
                username=config["SMB_USER"],
                password=config["SMB_PASSWORD"]
            )

            smb_input_dir = f"\\\\{config['SMB_SERVER']}\\{config['SMB_SHARE']}{config['SMB_INPUT_PATH']}"
            smb_output_dir = f"\\\\{config['SMB_SERVER']}\\{config['SMB_SHARE']}{config['SMB_OUTPUT_PATH']}"

            xlsx_file = None
            for entry in scandir(smb_input_dir):
                if entry.name.lower().endswith('.xlsx'):
                    xlsx_file = entry.name
                    break

            if not xlsx_file:
                raise FileNotFoundError(f"Не найден XLSX файл в {smb_input_dir}")

            result["processed_file"] = xlsx_file
            smb_file_path = f"{smb_input_dir}\\{xlsx_file}"
            logger.info(f"Найден файл: {smb_file_path}")

            with open_file(smb_file_path, mode="rb") as file:
                xlsx_bytes = file.read()

            binary = pd.ExcelFile(BytesIO(xlsx_bytes))

            for sheet in config["SHEETS_TO_CONVERT"]:
                if sheet in binary.sheet_names:
                    try:
                        df = pd.read_excel(binary, sheet_name=sheet)
                        csv_buffer = StringIO()
                        df.to_csv(csv_buffer, index=False, encoding='utf-8')
                        csv_data = csv_buffer.getvalue().encode('utf-8')

                        csv_name = f"{sheet.replace(' ', '_')}.csv"
                        smb_csv_path = f"{smb_output_dir}\\{csv_name}"

                        with open_file(smb_csv_path, mode="wb") as remote_csv:
                            remote_csv.write(csv_data)

                        result["converted_sheets"].append(sheet)
                        logger.info(f"{sheet} ОК")
                    except Exception as e:
                        logger.error(f"Ошибка обработки листа {sheet}: {str(e)}")
                else:
                    logger.warning(f"Лист \"{sheet}\" не найден в файле")

        except Exception as e:
            result["error"] = str(e)
            logger.error(f"Ошибка обработки: {str(e)}")

        return result

    process_xlsx_task(CONFIG)

xlsx_to_csv_dag = xlsx_to_csv()
