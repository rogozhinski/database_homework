DROP TABLE IF EXISTS account CASCADE;
DROP TABLE IF EXISTS applicant CASCADE;
DROP TABLE IF EXISTS employer CASCADE;
DROP TABLE IF EXISTS vacancy CASCADE;

DROP TYPE IF EXISTS FIELD CASCADE;
DROP TYPE IF EXISTS APPLICANT_MOBITILY CASCADE;
DROP TYPE IF EXISTS TOWN CASCADE;
DROP TYPE IF EXISTS SCHEDULE CASCADE;
DROP TYPE IF EXISTS EXP_DURATION CASCADE;

CREATE TYPE FIELD AS ENUM ('торговля', 'наука и образование', 'услуги', 'IT', 'промышленность', 
						   'сельхоз', 'медиа','общественная деятельность', 'другое');

CREATE TYPE APPLICANT_MOBITILY AS ENUM ('переезд', 'командировки');
								   
-- тут, конечно, нужна отдельная схема (или даже база) с деревом населенных пунктов России и не только --								   
CREATE TYPE TOWN AS ENUM ('Москва', 'Самара', 'Санкт-Петербург', 'Казань', 'Скотопригоньевск', 'не выбран');

-- график работы --
CREATE TYPE SCHEDULE AS ENUM ('гибкий график', 'полная занятость', 'неполная занятость', 'удаленная работа',
							 'вахтовый метод', 'ненормированный рабочий график');
							 
CREATE TYPE EXP_DURATION AS ENUM ('без опыта', '1-3 года', '3-6 лет', '6-15 лет', 'больше 15 лет');							 

-- Таблица учетных записей соискателей --
CREATE TABLE account (
	account_id 		SERIAL PRIMARY KEY,
	first_name 		VARCHAR(20) NOT NULL, 
	last_name 		VARCHAR(60) NOT NULL, 	-- на случай Ивана Сергеевича Пятитрясогусковича-Крестовоздвиженского --
	birth_date 		DATE NOT NULL,
	applicant_id	INT [], 				-- чтобы работодатель мог посмотреть, какие еще резюме публиковал этот соискатель --
	email 			VARCHAR(256),
	telephone_num 	VARCHAR(20)
);

-- Таблица резюме --
-- В эту таблицу входит та информация, которая касается непосредственно резюме о поиске работы --
-- Она будет использоваться работодателем при поиске соискателя (и работодателю на этом этапе действительно --
-- не так важны личные данные соискателя - имя, номер телефона и т.д.). --
CREATE TABLE applicant (
	applicant_id		SERIAL PRIMARY KEY,
	account_id 			INT NOT NULL, 			-- для доступа к учетной записи соискателя --
	cv_header			VARCHAR (100) NOT NULL,	-- то, что будет высвечиваться в качестве заголовка при поиске ("инженер-технолог") --
	applicant_field     FIELD DEFAULT 'другое',
	curriculum_vitae	VARCHAR (2000),			-- для текста резюме --
	external_link 		VARCHAR(500) [],		-- для грамот, портфолио и прочих загружаемых документов --
	min_salary			INT DEFAULT 0,			-- если желаемая зарплата не указана, то рассматриваем все варианты --
	max_salary			INT DEFAULT 100000000, 	-- а-ля бесконечность --
	init_location 		TOWN DEFAULT 'не выбран',
	experience 			EXP_DURATION NOT NULL,
	work_schedule		SCHEDULE [],			-- если соискатель рассматривает разные графики --
	ready_to_move		APPLICANT_MOBITILY []		-- аналог set из MySQL реализован как массив enum'ов --
);											-- то есть может быть несколько вариантов ответа (например, ['командировки', 'переезд']) --


-- Таблица компаний-работодателей --
CREATE TABLE employer (
	employer_id		SERIAL PRIMARY KEY,
	company_name 	VARCHAR(60) NOT NULL, 	-- на случай Ивана Сергеевича Пятитрясогусковича-Крестовоздвиженского --
	vacancy_id		INT [], 				-- список вакансий, предлагаемых данной компанией-работодателем --
	email 			VARCHAR(256),			-- контакты отдела кадров
	telephone_num 	VARCHAR(20)
);

-- Таблица предлагаемых вакансий -- 
CREATE TABLE vacancy (
	vacancy_id		SERIAL PRIMARY KEY,
	employer_id		INT NOT NULL,
	vacancy_header 	VARCHAR(100) NOT NULL, 		-- название вакансии (как заголовок в поиске)
	vacancy_field	FIELD NOT NULL,
	description		VARCHAR (2000) NOT NULL,	-- описание вакансии (график, рабочие обязанности)
	min_salary		INT DEFAULT 0,	
	max_salary		INT DEFAULT 100000000, 
	experience 		EXP_DURATION [], 			-- если конкретный опыт не критичен --
	external_link 	VARCHAR(500) [],			-- ссылка на сайт организации-работодателя --
	job_location 	TOWN,
	work_schedule	SCHEDULE [],				-- если работодатель рассматривает разные графики --
	ready_to_move   APPLICANT_MOBITILY []			-- указание потребностей работодателя в перемещении свжего сотрудника --
);	 
	 

