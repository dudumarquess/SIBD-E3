
-- ----------------------------------------------------------------------------
-- Sistemas de Informação e Bases de Dados - António Ferreira, DI-FCUL.
-- Tabelas para a etapa 3 do projeto de SIBD de 2023/2024.
-- ----------------------------------------------------------------------------

-- Motorista (nif, nome, genero, nascimento, localidade)
--      Taxi (matricula, ano, marca, conforto, eurosminuto)
--    Viagem (motorista, inicio, fim, taxi, passageiros)

-- ----------------------------------------------------------------------------
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';
DROP TABLE viagem;
DROP TABLE taxi;
DROP TABLE motorista;

-- ----------------------------------------------------------------------------

CREATE TABLE motorista (
  nif        NUMBER  (9),
  nome       VARCHAR (80) CONSTRAINT nn_motorista_nome       NOT NULL,
  genero     CHAR    (1)  CONSTRAINT nn_motorista_genero     NOT NULL,
  nascimento NUMBER  (4)  CONSTRAINT nn_motorista_nascimento NOT NULL,
  localidade VARCHAR (80) CONSTRAINT nn_motorista_localidade NOT NULL,
--
  CONSTRAINT pk_motorista
    PRIMARY KEY (nif),
--
  CONSTRAINT ck_motorista_nif  -- RIA 10.
    CHECK (nif BETWEEN 100000000 AND 999999999),
--
  CONSTRAINT ck_motorista_genero  -- RIA 11.
    CHECK (UPPER(genero) IN ('F', 'M')),  -- F(eminino), M(asculino).
--
  CONSTRAINT ck_motorista_nascimento  -- Não suporta RIA 6, mas
    CHECK (nascimento > 1900)         -- impede erros básicos.
);

-- ----------------------------------------------------------------------------

CREATE TABLE taxi (
  matricula   CHAR    (6),
  ano         NUMBER  (4)   CONSTRAINT nn_taxi_ano         NOT NULL,
  marca       VARCHAR (20)  CONSTRAINT nn_taxi_marca       NOT NULL,
  conforto    CHAR    (1)   CONSTRAINT nn_taxi_conforto    NOT NULL,
  eurosminuto NUMBER  (4,2) CONSTRAINT nn_taxi_eurosminuto NOT NULL,
--
  CONSTRAINT pk_taxi
    PRIMARY KEY (matricula),
--
  CONSTRAINT ck_taxi_matricula
    CHECK (LENGTH(matricula) = 6),
--
  CONSTRAINT ck_taxi_ano  -- Não suporta RIA 7, mas
    CHECK (ano > 1900),   -- impede erros básicos.
--
  CONSTRAINT ck_taxi_conforto  -- RIA 16.
    CHECK (UPPER(conforto) IN ('B', 'L')),  -- B(ásico), L(uxuoso).
--
  CONSTRAINT ck_taxi_eurosminuto  -- RIA 17 (adaptada a esta tabela).
    CHECK (eurosminuto > 0.0)
);

-- ----------------------------------------------------------------------------

CREATE TABLE viagem (
  motorista,
  inicio      DATE,
  fim         DATE       CONSTRAINT nn_viagem_fim         NOT NULL,
  taxi                   CONSTRAINT nn_viagem_taxi        NOT NULL,
  passageiros NUMBER (1) CONSTRAINT nn_viagem_passageiros NOT NULL,
--
  CONSTRAINT pk_viagem
    PRIMARY KEY (motorista, inicio),  -- Simplificação.
--
  CONSTRAINT fk_viagem_motorista
    FOREIGN KEY (motorista)
    REFERENCES motorista (nif),
--
  CONSTRAINT fk_viagem_taxi
    FOREIGN KEY (taxi)
    REFERENCES taxi (matricula),
--
  CONSTRAINT ck_viagem_periodo  -- RIA 5 (adaptada a esta tabela).
    CHECK (inicio < fim),
--
  CONSTRAINT ck_viagem_passageiros  -- RIA 19.
    CHECK (passageiros BETWEEN 1 AND 8)
);

-- ----------------------------------------------------------------------------
INSERT INTO motorista (nif, nome, genero, nascimento, localidade)
    VALUES (598745612, 'Paula Afonso', 'F', 1995, 'Lisboa');
    
INSERT INTO motorista (nif, nome, genero, nascimento, localidade)
    VALUES (123456789, 'Eduardo Afonso', 'M', 1986, 'Porto');

INSERT INTO motorista (nif, nome, genero, nascimento, localidade)
    VALUES (153648952, 'Maria Afonso', 'F', 2002, 'Oeiras');
    
INSERT INTO motorista (nif, nome, genero, nascimento, localidade)
    VALUES (456321456, 'Gabriel Nakamura', 'M', 1996, 'Lisboa');  
    
INSERT INTO motorista (nif, nome, genero, nascimento, localidade)
    VALUES (578212346, 'Goncalo Baldaia', 'M', 1956, 'Lisboa');
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
    VALUES ('BX45YS', 2018, 'Mercedes', 'L', 0.9);
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
    VALUES ('AB01CD', 2020, 'BMW', 'L', 0.6);
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
    VALUES ('GS45JS', 2019, 'Renault', 'B', 0.3);
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
    VALUES ('AB87FG', '2016', 'Lancia', 'B', 0.5);
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
    VALUES ('HS06JS', '2020', 'Lexus', 'L', 1.2);
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
    VALUES ('KS75LS', '2022', 'Lexus', 'L', 1.1);
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
    VALUES ('HR76IO', '2019', 'Lexus', 'L', 0.7);
    
INSERT INTO taxi (matricula, ano, marca, conforto, eurosminuto)
    VALUES ('SG86LS', '1998', 'Opel', 'B', 0.3);
    
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (598745612, TO_DATE('31.12.2022 23:00:00', 'DD.MM.YYYY HH24:MI:SS'), 
    TO_DATE('01.01.2023 02:00:00', 'DD.MM.YYYY HH24:MI:SS'),'BX45YS', 3);
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (123456789, TO_DATE('22.05.2023 05:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('22.05.2023 09:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'AB01CD',2);
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (153648952, TO_DATE('29.07.2023 13:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('29.07.2023 15:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'BX45YS',4);

INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (123456789, TO_DATE('29.07.2022 13:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('29.07.2022 15:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'AB87FG',2);  
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (123456789, TO_DATE('22.05.2022 05:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('22.05.2022 09:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'AB87FG',2);
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (123456789, TO_DATE('28.03.2021 05:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('28.03.2021 09:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'AB87FG',2);
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (123456789, TO_DATE('28.03.2021 05:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('28.03.2021 09:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'AB87FG',2);
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (123456789, TO_DATE('28.03.2003 05:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('28.03.2003 09:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'SG86LS',1);

INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (123456789, TO_DATE('28.07.2018 07:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('28.07.2018 09:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'HS06JS',2);
    
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (598745612, TO_DATE('28.07.2018 09:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('28.07.2018 10:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'HS06JS',3);  
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (456321456, TO_DATE('31.07.2019 10:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('31.07.2019 10:30:00', 'DD.MM.YYYY HH24:MI:SS'), 'HS06JS',4);  

INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (578212346, TO_DATE('31.07.2019 08:10:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('31.07.2019 10:30:00', 'DD.MM.YYYY HH24:MI:SS'), 'HS06JS',1);  
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (598745612, TO_DATE('28.04.2018 09:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('28.04.2018 10:00:00', 'DD.MM.YYYY HH24:MI:SS'), 'HR76IO',3);  
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (456321456, TO_DATE('31.05.2019 10:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('31.05.2019 10:30:00', 'DD.MM.YYYY HH24:MI:SS'), 'HR76IO',4);  

INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (456321456, TO_DATE('25.05.2019 10:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('25.05.2019 10:30:00', 'DD.MM.YYYY HH24:MI:SS'), 'HR76IO',4);   
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (578212346, TO_DATE('24.05.2018 10:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('25.05.2018 10:30:00', 'DD.MM.YYYY HH24:MI:SS'), 'HS06JS',4);
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (153648952, TO_DATE('26.05.2018 10:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('27.05.2018 10:30:00', 'DD.MM.YYYY HH24:MI:SS'), 'HS06JS',4);     
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (153648952, TO_DATE('22.05.2017 10:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('22.05.2017 10:30:00', 'DD.MM.YYYY HH24:MI:SS'), 'AB87FG',4);
        
INSERT INTO viagem (motorista, inicio, fim, taxi, passageiros)
    VALUES (598745612, TO_DATE('23.05.2017 10:00:00', 'DD.MM.YYYY HH24:MI:SS'),
        TO_DATE('23.05.2017 10:30:00', 'DD.MM.YYYY HH24:MI:SS'), 'AB87FG',4); 
