DROP DATABASE test IF EXISTS;

CREATE DATABASE test;

DROP user admin IF EXISTS;

CREATE USER admin WITH ENCRYPTED PASSWORD 'admin';

\c test;

GRANT ALL PRIVILEGES ON DATABASE test TO admin;

CREATE SCHEMA "DWH" AUTHORIZATION admin;

CREATE TABLE "DWH".brand (
    id UUID NOT NULL,
    description TEXT NULL,
    CONSTRAINT brand_pkey PRIMARY KEY (id)
);

ALTER TABLE "DWH".brand OWNER TO admin;
GRANT TRIGGER, UPDATE, INSERT, TRUNCATE, DELETE, SELECT, REFERENCES ON TABLE "DWH".brand TO admin;


CREATE TABLE "DWH".order (
    id UUID NOT NULL,
    sum INT4 NULL,
    CONSTRAINT order_pkey PRIMARY KEY (id)
);

ALTER TABLE "DWH".order OWNER TO admin;
GRANT TRIGGER, UPDATE, INSERT, TRUNCATE, DELETE, SELECT, REFERENCES ON TABLE "DWH".order TO admin;


CREATE TABLE "DWH".store (
    id UUID NOT NULL,
    description TEXT NULL,
    CONSTRAINT store_pkey PRIMARY KEY (id)
);

ALTER TABLE "DWH".store OWNER TO admin;
GRANT TRIGGER, UPDATE, INSERT, TRUNCATE, DELETE, SELECT, REFERENCES ON TABLE "DWH".store TO admin;


CREATE TABLE "DWH".product (
    id UUID NOT NULL,
    description TEXT NULL,
    brand UUID NULL,
    CONSTRAINT product_pkey PRIMARY KEY (id),
    CONSTRAINT product_brand_fk FOREIGN KEY (brand) REFERENCES "DWH".brand(id)
);

ALTER TABLE "DWH".product OWNER TO admin;
GRANT TRIGGER, UPDATE, INSERT, TRUNCATE, DELETE, SELECT, REFERENCES ON TABLE "DWH".product TO admin;

INSERT INTO "DWH".brand (id,description) VALUES
	 ('9659ae3f-ce65-463e-a24d-8fb577f83e50'::uuid,'Бренд 1'),
	 ('c6daab5a-42d7-4858-bd40-fd5fe1b2a311'::uuid,'Бренд 2'),
	 ('0125d395-cafc-4341-b0c3-a639c1352494'::uuid,'Бренд 3'),
	 ('e55da987-9d95-4210-9c5a-691f5cab3f19'::uuid,'Бренд 4'),
	 ('1a62c6d7-4c83-4e01-9fcc-8efe0fc67dfe'::uuid,'Бренд 5'),
	 ('1f4a87d2-a6e3-4ba7-aea5-e923d4ff86e0'::uuid,'Бренд 6'),
	 ('72e25f77-74be-4c79-878a-d31d56d638e6'::uuid,'Бренд 7'),
	 ('77d46b55-63ec-45d8-90aa-ead1d47d2410'::uuid,'Бренд 8'),
	 ('dc8fe94f-69b2-4c5f-8c27-c2b50cd26be9'::uuid,'Бренд 9'),
	 ('1978fb35-6c45-4611-89f2-75db04a78d60'::uuid,'Бренд 10');
INSERT INTO "DWH".brand (id,description) VALUES
	 ('5b909fdf-5f94-470a-9d49-9a002c934301'::uuid,'Бренд 11'),
	 ('a8073f83-236f-4024-a223-9b3f75d3ca11'::uuid,'Бренд 12'),
	 ('ed3418ba-08ec-4f81-9460-a6ac219e26c7'::uuid,'Бренд 13'),
	 ('1dd129e6-24c2-4716-b199-d668c359cda0'::uuid,'Бренд 14'),
	 ('faac08eb-a0d0-47db-be79-d96290b82424'::uuid,'Бренд 15'),
	 ('ec2a3850-ad14-47a5-8da6-0154db654866'::uuid,'Бренд 16'),
	 ('1aecbb86-82aa-4db9-8c2a-94e1e3a320d0'::uuid,'Бренд 17'),
	 ('c14cf86e-57df-4111-be3f-4c1c2afa7f63'::uuid,'Бренд 18'),
	 ('ecbf9864-3316-421f-bb3d-4302b0d9624c'::uuid,'Бренд 19'),
	 ('7184f918-d3a5-4124-8003-afdaba81e4ef'::uuid,'Бренд 20');
INSERT INTO "DWH".brand (id,description) VALUES
	 ('415a9874-f94e-4182-9939-ab39e9610dba'::uuid,'Бренд 21'),
	 ('c21aea0b-66d1-4c0d-8b60-eee824fa49fe'::uuid,'Бренд 22'),
	 ('8ea9794f-4f2b-4854-b799-c9f4adf09836'::uuid,'Бренд 23'),
	 ('0b74c650-754e-487d-9434-47455d8c4e8d'::uuid,'Бренд 24'),
	 ('cdadda01-2780-4619-8b58-a02d8edd98b9'::uuid,'Бренд 25'),
	 ('fef15718-8d97-4367-8f06-d4d964a76e8b'::uuid,'Бренд 26'),
	 ('7d381a35-7901-4ab7-956c-86fb6eff50cb'::uuid,'Бренд 27');


INSERT INTO "DWH".order (id,sum) VALUES
	 ('5fdafb84-f65f-4129-bb76-049cb405256a'::uuid,100),
	 ('4e7cbf96-abac-4fbd-9181-5341c8938775'::uuid,200),
	 ('3f233bf1-9445-49ed-bbb2-b457e6a08e19'::uuid,300),
	 ('76f8b512-91e6-481f-8ed4-f19498fb5aab'::uuid,400),
	 ('ea18d1ab-abcb-42ab-b29d-f94afe80f7c1'::uuid,500),
	 ('908d5657-4c8a-4a38-897c-c1f502d8d93a'::uuid,600),
	 ('5da1e6e3-28cd-4830-8226-f146f7b2c687'::uuid,700),
	 ('a8ed225b-dfd2-4552-8703-315170706fef'::uuid,800),
	 ('36c84755-fe4f-44d0-add2-374a326fbd2c'::uuid,900),
	 ('865214b5-7482-407b-985a-67aeec908f7a'::uuid,1000);
INSERT INTO "DWH".order (id,sum) VALUES
	 ('5c3e7b32-2352-4562-9195-f3668bf1bead'::uuid,1100),
	 ('54955a9c-c617-4ee2-82d7-e6887d56f95b'::uuid,1200),
	 ('9716c164-a154-4f19-8a2f-47ba80bbf04a'::uuid,1300),
	 ('8fa5e258-61e5-49a2-9b79-a38455b174fc'::uuid,1400),
	 ('03a6848d-2fe8-4ebe-9009-c15d21b97312'::uuid,1500),
	 ('659b97a6-f682-48f5-b0cb-29acdd9062a0'::uuid,1600),
	 ('4b14ff2d-3a84-43cc-a1c8-2ef9b688484c'::uuid,1700),
	 ('1acc26d2-a477-4bfd-a030-6086d8b87814'::uuid,1800),
	 ('cca0cd06-400a-4570-b40d-60a58ee518d0'::uuid,1900),
	 ('9e86c790-b069-4b89-bfbe-0f907a79cc93'::uuid,2000);
INSERT INTO "DWH".order (id,sum) VALUES
	 ('0b54e78e-c3aa-469e-bc84-24bf21b5a7e7'::uuid,2100),
	 ('00f37b31-f91f-4ce5-8586-4654a8b92948'::uuid,2200),
	 ('fed544c9-7397-4b03-99fe-b454bf8a0027'::uuid,2300),
	 ('7e019a3e-d75c-4713-b3b4-473d4c36a3d2'::uuid,2400),
	 ('d079026f-56c7-4b06-bc16-a7d2e839d913'::uuid,2500),
	 ('6e8eb7ae-bde5-471a-a8cf-440f19ff1fa5'::uuid,2600),
	 ('828918be-f908-49aa-ac5e-aa3c880cd00a'::uuid,2700);

INSERT INTO "DWH".product (id,description,brand) VALUES
	 ('8e3ca679-6869-4308-ac44-485cfa308144'::uuid,'Товар 1','9659ae3f-ce65-463e-a24d-8fb577f83e50'::uuid),
	 ('d54535f7-2d5f-4f2d-a364-01f110b46765'::uuid,'Товар 2','c6daab5a-42d7-4858-bd40-fd5fe1b2a311'::uuid),
	 ('277f11f7-9629-4c9e-8adb-426a960235e7'::uuid,'Товар 3','0125d395-cafc-4341-b0c3-a639c1352494'::uuid),
	 ('b819cd69-d8e1-486f-8f63-a2d2853a2126'::uuid,'Товар 4','e55da987-9d95-4210-9c5a-691f5cab3f19'::uuid),
	 ('faab0200-d265-48dc-b6bf-7bfb60fdc14a'::uuid,'Товар 5','1a62c6d7-4c83-4e01-9fcc-8efe0fc67dfe'::uuid),
	 ('c91c98df-551f-4bd7-af50-d7318c02a8e7'::uuid,'Товар 6','1f4a87d2-a6e3-4ba7-aea5-e923d4ff86e0'::uuid),
	 ('30c8fd0c-35a6-4248-a40e-e1468d0f712b'::uuid,'Товар 7','72e25f77-74be-4c79-878a-d31d56d638e6'::uuid),
	 ('d0f00270-8b51-4f90-8709-f13406e30e16'::uuid,'Товар 8','77d46b55-63ec-45d8-90aa-ead1d47d2410'::uuid),
	 ('d20547bf-a205-44ea-9eac-42c8a5edaea8'::uuid,'Товар 9','dc8fe94f-69b2-4c5f-8c27-c2b50cd26be9'::uuid),
	 ('9805f336-aeb9-43e6-a38a-5bb1be3df434'::uuid,'Товар 10','1978fb35-6c45-4611-89f2-75db04a78d60'::uuid);
INSERT INTO "DWH".product (id,description,brand) VALUES
	 ('9d57caa4-46c5-4766-aac3-153f08576130'::uuid,'Товар 11','5b909fdf-5f94-470a-9d49-9a002c934301'::uuid),
	 ('1641d915-38cc-4738-84e1-7303a115bf7f'::uuid,'Товар 12','a8073f83-236f-4024-a223-9b3f75d3ca11'::uuid),
	 ('8f1727a0-ef1c-4bf0-bf76-039677888438'::uuid,'Товар 13','ed3418ba-08ec-4f81-9460-a6ac219e26c7'::uuid),
	 ('abaa96cd-f1e3-4be2-87bd-22678f7074de'::uuid,'Товар 14','1dd129e6-24c2-4716-b199-d668c359cda0'::uuid),
	 ('ff59affb-2614-4e0f-bc30-7843bc6b88d5'::uuid,'Товар 15','faac08eb-a0d0-47db-be79-d96290b82424'::uuid),
	 ('9303260c-2c26-4daa-b5e5-0a5f321c4f6b'::uuid,'Товар 16','ec2a3850-ad14-47a5-8da6-0154db654866'::uuid),
	 ('e119b33b-e44f-4ccc-a46c-bf7eb8770ba3'::uuid,'Товар 17','1aecbb86-82aa-4db9-8c2a-94e1e3a320d0'::uuid),
	 ('c87e6680-0c02-4a89-91c8-2420e7455cb0'::uuid,'Товар 18','c14cf86e-57df-4111-be3f-4c1c2afa7f63'::uuid),
	 ('c38c231b-3e92-4554-bce7-400b37259f76'::uuid,'Товар 19','ecbf9864-3316-421f-bb3d-4302b0d9624c'::uuid),
	 ('ee4c9e6d-b6b3-46c4-a19a-0c8f03b68c51'::uuid,'Товар 20','7184f918-d3a5-4124-8003-afdaba81e4ef'::uuid);
INSERT INTO "DWH".product (id,description,brand) VALUES
	 ('df6ecff0-1899-4cae-bad5-27adff560972'::uuid,'Товар 21','415a9874-f94e-4182-9939-ab39e9610dba'::uuid),
	 ('81c850bb-9893-4b7e-8591-f6efc2af91ba'::uuid,'Товар 22','c21aea0b-66d1-4c0d-8b60-eee824fa49fe'::uuid),
	 ('c9fe243d-04c7-47d7-b14b-554ef51d0fe6'::uuid,'Товар 23','8ea9794f-4f2b-4854-b799-c9f4adf09836'::uuid),
	 ('886c01ae-c457-4032-9df0-0d074b71f73f'::uuid,'Товар 24','0b74c650-754e-487d-9434-47455d8c4e8d'::uuid),
	 ('f177331f-c6bf-46de-a920-b6460b740628'::uuid,'Товар 25','cdadda01-2780-4619-8b58-a02d8edd98b9'::uuid),
	 ('4bc873d7-860e-439a-b8ef-ef13196c17a9'::uuid,'Товар 26','fef15718-8d97-4367-8f06-d4d964a76e8b'::uuid),
	 ('d61203c7-8a1f-4a9d-9ad4-4f9ce804210d'::uuid,'Товар 27','7d381a35-7901-4ab7-956c-86fb6eff50cb'::uuid);


INSERT INTO "DWH".store (id,description) VALUES
	 ('48768284-5eb6-4cfb-8c45-2f4123046ae1'::uuid,'Магазин 1'),
	 ('5c3aefe1-ec98-4354-92df-a19a50f0ed95'::uuid,'Магазин 2'),
	 ('2a7c3e9b-1541-459f-afce-ec3114935249'::uuid,'Магазин 3'),
	 ('35cf63a5-cf29-4c84-89fd-0bd5aea6e863'::uuid,'Магазин 4'),
	 ('374b0221-49b5-4cde-9f91-8409395f752a'::uuid,'Магазин 5'),
	 ('8268f8ff-20c9-46be-98a3-dc389062efcd'::uuid,'Магазин 6'),
	 ('3cdc9ee9-e6bc-415d-8b3d-0cca80b4bcc5'::uuid,'Магазин 7'),
	 ('05618955-65d8-4abc-8305-3f8a7d1f40f2'::uuid,'Магазин 8'),
	 ('b2fcf103-6f18-4251-a61b-96366078fc89'::uuid,'Магазин 9'),
	 ('d3c112dd-cda5-445c-a511-944dafff8c5b'::uuid,'Магазин 10');
INSERT INTO "DWH".store (id,description) VALUES
	 ('f49d2149-cb98-4198-9df6-79884a0b9736'::uuid,'Магазин 11'),
	 ('6f265826-63fa-4d56-83bf-d883ffbf0784'::uuid,'Магазин 12'),
	 ('2622cea5-997e-4124-99a4-7a40fd45bc40'::uuid,'Магазин 13'),
	 ('81f4e9a3-378a-43eb-af0d-9cfff0ebfe1c'::uuid,'Магазин 14'),
	 ('c6e79c4e-5a22-4850-972e-14ae94a8f7e2'::uuid,'Магазин 15'),
	 ('b5a54f9f-2809-4d66-b3e5-6e44219ae923'::uuid,'Магазин 16'),
	 ('b3f64e5a-383c-4935-b3e7-94500f1f951b'::uuid,'Магазин 17'),
	 ('745fc791-a6dc-4f29-84e1-75fa13ad01cb'::uuid,'Магазин 18'),
	 ('1022ddc0-52dc-4606-89ee-38ec3f4c00b6'::uuid,'Магазин 19'),
	 ('2b1c83f1-3085-4b17-8452-f67da979500a'::uuid,'Магазин 20');
INSERT INTO "DWH".store (id,description) VALUES
	 ('82311ded-e6e3-45af-a085-cfd37206cb87'::uuid,'Магазин 21'),
	 ('7016a963-4044-4b19-a557-07437e8e2627'::uuid,'Магазин 22'),
	 ('30e07180-b557-45c8-9764-4db5d8c729da'::uuid,'Магазин 23'),
	 ('764d0dd4-ee65-4f4f-8dea-2b72fa6723f6'::uuid,'Магазин 24'),
	 ('010a939e-00dd-4e9b-8e44-e1ce3f0406a8'::uuid,'Магазин 25'),
	 ('f98b81ed-c627-437a-8ba4-4699ff2886ab'::uuid,'Магазин 26'),
	 ('d33a1ea7-ae23-4fbc-9011-a8843029a1e6'::uuid,'Магазин 27');
