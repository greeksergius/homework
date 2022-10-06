CREATE TABLE itprod.personal (
	idper int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	fio varchar NOT NULL,
	salary int NULL,
	datehairng date NULL,
	idpost int4 NULL,
	idtypediv int4 NULL,
	idnamediv int4 NULL,
	idaddresfil int4 NULL,
	idproject int4 NULL
);

-- Column comments

COMMENT ON COLUMN itprod.personal.idper IS 'ИД';
COMMENT ON COLUMN itprod.personal.fio IS 'ФИО';
COMMENT ON COLUMN itprod.personal.salary IS 'Оклад';
COMMENT ON COLUMN itprod.personal.datehairng IS 'Дата найма';
COMMENT ON COLUMN itprod.personal.idpost IS 'Ид должности';
COMMENT ON COLUMN itprod.personal.idtypediv IS 'Ид типа подразделения';
COMMENT ON COLUMN itprod.personal.idnamediv IS 'Ид структурного подразделения';
COMMENT ON COLUMN itprod.personal.idaddresfil IS 'Ид адреса филила';
COMMENT ON COLUMN itprod.personal.idproject IS 'Ид названия проекта';

CREATE TABLE itprod.post (
	idpost int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	post varchar NOT NULL
);



CREATE TABLE itprod.typedivision (
	idtd int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	subdivisiontitle varchar NOT NULL
);


CREATE TABLE itprod.namesubdivision (
	idnd int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	namesubdivtitle varchar NOT NULL
);


CREATE TABLE itprod.addressfil (
	idfa int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	addfiltitile varchar NOT NULL
);



CREATE TABLE itprod.project (
	idproj int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	projecttitle varchar NOT NULL
);
