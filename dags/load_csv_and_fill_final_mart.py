from airflow.decorators import task, dag
from datetime import datetime

PG_CONFIG = {#Параметры подключения должны быть заданы через airflow connections
    "host": "localhost",
    "port": 5432,
    "database": "test",
    "user": "admin",
    "password": "admin",
    "schema": "DWH"
}

SMB_CONFIG = {#Параметры smb шары должн ыбыть заданы через переменные airflow
    "SMB_SERVER":      "192.168.0.105",
    "SMB_SHARE":       "share",
    "SMB_OUTPUT_PATH": "/test_5element/csv_output",
    "SMB_USER":        "elem5",
    "SMB_PASSWORD":    "elem5"
}

CSV_TO_TABLE = {
    "Из внешних источников": "reviews_external",
    "Другое":                "reviews_other",
    "Отзывы на товары":      "reviews_products",
    "Отзывы на магазины":    "reviews_stores",
    "Опросы":                "reviews_survey"
}

@task.virtualenv(
    requirements=[
        "numpy==1.26.4",
        "pandas==2.1.4",
        "openpyxl==3.1.2",
        "smbprotocol==1.10.1",
        "psycopg2-binary",
        "requests"
    ],
    system_site_packages=False
)
def process_csv_task(postgres_cfg, smb_cfg, csv_name_dict):
    import logging
    import pandas as pd
    import psycopg2
    from smbclient import register_session, open_file
    from io import TextIOWrapper, StringIO
    import requests
    import random
    import os

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)

    def correct_with_yandex(text: str) -> str:
        if pd.isna(text) or not str(text).strip():
            return text
        try:
            resp = requests.get(#Исправление лексических ошибок через яндекс спеллер
                "https://speller.yandex.net/services/spellservice.json/checkText",
                params={"text": text, "lang": "ru"},
                timeout=5
            )
            resp.raise_for_status()
            errors = resp.json()
            corrected = list(text)
            offset_shift = 0
            for err in errors:
                word = err["word"]
                suggestion = err.get("s", [word])[0]
                pos = err["pos"] + offset_shift
                corrected[pos:pos+len(word)] = list(suggestion)
                offset_shift += len(suggestion) - len(word)
            return "".join(corrected)
        except Exception as e:
            logger.warning(f"Ошибка при проверке лексики: {e}")
            return text

    register_session(
        server=smb_cfg["SMB_SERVER"],
        username=smb_cfg["SMB_USER"],
        password=smb_cfg["SMB_PASSWORD"]
    )

    smb_dir = f"\\\\{smb_cfg['SMB_SERVER']}\\{smb_cfg['SMB_SHARE']}{smb_cfg['SMB_OUTPUT_PATH']}"
    conn = psycopg2.connect(
        host=postgres_cfg["host"],
        port=postgres_cfg["port"],
        dbname=postgres_cfg["database"],
        user=postgres_cfg["user"],
        password=postgres_cfg["password"],
        options=f"-csearch_path={postgres_cfg['schema']}"
    )
    conn.autocommit = False
    cur = conn.cursor()

    for sheet, table in csv_name_dict.items():
        file_name = f"{sheet.replace(' ', '_')}.csv"
        path = f"{smb_dir}\\{file_name}"
        try:
            logger.info(f"Чтение {file_name}")
            with open_file(path, mode="rb") as raw:
                df = pd.read_csv(TextIOWrapper(raw, encoding="utf-8"))

            cols_to_fix = [col for col in df.columns if ("тип" in col.lower()) or ("тема" in col.lower())] # исправление ошибок в полях со словами "тип" или "тема"
            for col in cols_to_fix:
                df[col] = df[col].astype(str).apply(correct_with_yandex)

            if sheet == "Опросы":
                question_cols = [col for col in df.columns if "вопрос" in col.lower()]
                for col in question_cols:
                    df[col] = [random.randint(1, 10) for _ in range(len(df))]

            buf = StringIO()
            df.to_csv(buf, index=False)
            buf.seek(0)
            sql = f'COPY "{postgres_cfg["schema"]}"."{table}" FROM STDIN WITH CSV HEADER'
            cur.copy_expert(sql, buf)
            conn.commit()

            try: #Удаление csv после обработки
                os.remove(path)
                logger.info(f"Файл {file_name} удалён после обработки.")
            except Exception as e:
                logger.warning(f"Не удалось удалить файл {file_name}: {e}")


        except Exception as e:
            conn.rollback()
            logger.error(f"Ошибка при обработке {file_name}: {e}", exc_info=True)

    cur.close()
    conn.close()


@task.virtualenv(requirements=["psycopg2-binary"], system_site_packages=False)#Таска вставки данных в итоговую таблицу, лучше использовать PostgresOperator, хранить запрос в отдельном файле
def aggregate_reviews_task(postgres_cfg):
    import psycopg2

    sql = '''
    INSERT INTO "DWH".reviews_final
    WITH
      other AS (
        SELECT COALESCE("Номер A"::text, "Номер B"::text) AS "ID",
               "Дата"::date, "Источник", "Тип", "Тема", "Вопрос в теме",
               "Магазин", "Резюме" AS "Содержание"
        FROM "DWH".reviews_other
      ),
      products AS (
        SELECT "ID"::text, "Дата"::date, 'Отзывы на товары', "Тип отзыва",
               "Тема отзыва", "Вопрос в теме отзыва", NULL, "Резюме"
        FROM "DWH".reviews_products
      ),
      stores AS (
        SELECT "ID"::text, "Дата"::date, 'Отзывы на магазины', "Тип отзыва",
               "Тема отзыва", "Вопрос в теме отзыва", "Адрес магазина", "Резюме"
        FROM "DWH".reviews_stores
      ),
      externals AS (
        SELECT "ID"::text, "Дата"::date, "Источник", "Тип отзыва",
               "Тема отзыва", "Вопрос в теме отзыва", "Магазин", "Резюме"
        FROM "DWH".reviews_external
      ),
      surveys AS (
        SELECT "ID анкеты"::text, "Дата опроса"::date, 'Опросы', "ТипBPM",
               "Тема", "Вопрос в теме", "Магазин", "Комментарий"
        FROM "DWH".reviews_survey
      )
    SELECT * FROM other
    UNION ALL SELECT * FROM products
    UNION ALL SELECT * FROM stores
    UNION ALL SELECT * FROM externals
    UNION ALL SELECT * FROM surveys;
    '''

    conn = psycopg2.connect(
        host=postgres_cfg["host"],
        port=postgres_cfg["port"],
        dbname=postgres_cfg["database"],
        user=postgres_cfg["user"],
        password=postgres_cfg["password"],
        options=f"-csearch_path={postgres_cfg['schema']}"
    )
    cur = conn.cursor()
    cur.execute(sql)
    conn.commit()
    cur.close()
    conn.close()


@task.virtualenv(requirements=["psycopg2-binary"], system_site_packages=False)#Таска обновления индексов итоговой таблицы
def update_indexes_task(postgres_cfg):
    import psycopg2

    index_names = [
        "idx_reviews_final_source",
        "idx_reviews_final_theme",
        "idx_reviews_final_type",
        "reviews_final_pk"
    ]

    conn = psycopg2.connect(
        host=postgres_cfg["host"],
        port=postgres_cfg["port"],
        dbname=postgres_cfg["database"],
        user=postgres_cfg["user"],
        password=postgres_cfg["password"],
        options=f"-csearch_path={postgres_cfg['schema']}"
    )
    conn.autocommit = True  # Важно для REINDEX CONCURRENTLY
    cur = conn.cursor()

    for index in index_names:
        try:
            cur.execute(f'REINDEX INDEX CONCURRENTLY "{index}";')
        except psycopg2.Error as e:
            print(f"Ошибка при REINDEX {index}: {e.pgerror}")

    cur.close()
    conn.close()


@dag(schedule=None, start_date=datetime(2025, 7, 1), catchup=False)
def load_csv_dag():
    t1 = process_csv_task(PG_CONFIG, SMB_CONFIG, CSV_TO_TABLE)
    t2 = aggregate_reviews_task(PG_CONFIG)
    t3 = update_indexes_task(PG_CONFIG)

    t1 >> t2 >> t3

load_csv_dag = load_csv_dag()
