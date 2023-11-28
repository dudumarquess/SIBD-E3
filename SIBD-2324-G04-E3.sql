-- ----------------------------------------------------------------------
-- SIBD 2023-2024.
-- Etapa 2 do projeto, Grupo n? 04.
-- Eduardo Marques 59798, TP 14;
-- Gabriel Nakamura 59842, TP 14;
-- Gon�alo Silveira 59866, TP 12;
-- B�rbara Rosa 56287, TP 13.
-- ----------------------------------------------------------------------
-- Contribui��es: Fizemos o trabalho em conjunto, sendo assim, todos os 
-- participantes t�m todos a mesma percentagem de contribui��o, 25% cada.

-- ----------------------------------------------------------------------
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';
-- ----------------------------------------------------------------------
-- Motorista (nif, nome, genero, nascimento, localidade)
--      Taxi (matricula, ano, marca, conforto, eurosminuto)
--    Viagem (motorista, inicio, fim, taxi, passageiros)
-- ----------------------------------------------------------------------
-- 1. NIF, nome, e idade das motoristas femininas com apelido Afonso, que conduziram em vi-
-- agens com tr�s ou mais passageiros, em t�xis com conforto luxuoso, durante o ano de
-- 2023, incluindo o caso particular da noite da passagem de ano, em que uma viagem pode
-- ter come�ado em 2022 e terminado j� em 2023. A matr�cula e a marca do(s) t�xi(s) tam-
-- b�m devem ser mostradas. O resultado deve vir ordenado de forma ascendente pela idade
-- e nome das motoristas, e de forma descendente pela marca e matr�cula dos t�xis. Nota: a
-- extra��o do ano a partir de uma data pode ser feita usando TO_CHAR(data, 'YYYY').
-- Variantes com menor cota��o: a) sem o c�lculo da idade das motoristas; e b) sem a verifi-
-- ca��o do caso da noite da passagem de ano.
 
 SELECT M.nif, M.nome, TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) - M.nascimento AS idade,
        T.matricula, T.marca 
   FROM motorista M, viagem V, taxi T
  WHERE (M.nif = V.motorista)
    AND (V.taxi = T.matricula)
    AND (M.genero = 'F')
    AND (UPPER(SUBSTR(M.nome, INSTR(M.nome, ' ')+1)) = 'AFONSO')
    AND (V.passageiros >= 3)
    AND (T.conforto = 'L')
    AND ((TO_CHAR(V.inicio, 'YYYY') = '2023') OR 
       ((TO_CHAR(V.inicio, 'YYYY') = '2022') AND (TO_CHAR(V.fim, 'YYYY') = '2023')))
  ORDER BY idade ASC, M.nome ASC, T.marca DESC, T.matricula DESC;
 
-- 2. NIF e nome dos motoristas masculinos que, considerando apenas viagens iniciadas em
-- 2022 (n�o deve ser considerada a data de fim das viagens), ou n�o conduziram t�xis da
-- marca Lancia ou conduziram t�xis dessa marca em at� duas viagens. Adicionalmente, os
-- motoristas resultantes n�o podem ter conduzido t�xis comprados antes de 2000, indepen-
-- dentemente do ano das viagens. O resultado deve vir ordenado pelo nome dos motoristas
-- de forma ascendente e pelo NIF de forma descendente.
-- Variantes com menor cota��o: a) sem a verifica��o dos motoristas nunca terem conduzido
-- t�xis comprados antes de 2000; e b) sem a verifica��o do n�mero de viagens que conduzi-
-- ram em 2022.

SELECT DISTINCT M1.nif, M1.nome
  FROM motorista M1, viagem V1, taxi T1
 WHERE (M1.nif = V1.motorista)
   AND (V1.taxi = T1.matricula)
   AND (M1.genero = 'M')
   AND (TO_CHAR(V1.inicio, 'YYYY') = '2022')
   AND (T1.ano >= 2000) 
   AND ((UPPER(T1.marca) <> 'LANCIA') OR (SELECT COUNT (*)
                                            FROM viagem V2, taxi T2
                                           WHERE (V2.motorista = M1.nif)
                                             AND (V2.taxi = T2.matricula)
                                             AND (TO_CHAR(V2.inicio, 'YYYY') = '2022')
                                             AND (UPPER(T2.marca) = 'LANCIA'))<= 2)
   AND NOT EXISTS (SELECT *
                     FROM viagem V3, taxi T3
                    WHERE (V3.motorista = M1.nif)
                      AND (V3.taxi = T3.matricula)
                      AND (T3.ano < 2000))
 ORDER BY M1.nome ASC, M1.nif DESC;
 --           
-- -------------------------------------------------------------------------
-- 3.Todos os dados dos t�xis da marca Lexus, com pre�o por minuto acima da m�dia dos pre-
-- �os por minuto de todos os t�xis (independentemente da marca), e que tenham sido algu-
-- ma vez conduzidos por todos os motoristas de Lisboa na parte da manh� dos dias, mais
-- precisamente entre as 6h00 e as 11h59. Para simplificar, consideram-se apenas as viagens
-- iniciadas de manh� (a data de fim das viagens deve ser ignorada). O resultado deve vir
-- ordenado pelo pre�o por minuto dos t�xis de forma descendente e pela matr�cula dos t�xis
-- de forma ascendente. Nota: a extra��o da hora do dia a partir de uma data pode ser feita
-- usando TO_CHAR(data, 'HH24').
-- Variantes com menor cota��o: a) sem a verifica��o do pre�o por minuto dos t�xis ser su-
-- perior � m�dia dos pre�os por minuto de todos os t�xis; e b) sem as verifica��es da locali-
-- dade dos motoristas e da hora das viagens.

SELECT T.matricula, T.marca, T.ano, T.conforto,T.eurosminuto AS euros_por_minuto
  FROM taxi T
 WHERE (UPPER(T.marca) = 'LEXUS')
   AND (T.eurosminuto > (SELECT AVG(T.eurosminuto)
                            FROM taxi T))
   AND NOT EXISTS (SELECT *
                     FROM motorista M
                    WHERE (UPPER(M.localidade) = 'LISBOA')
                      AND NOT EXISTS (SELECT *
                                        FROM viagem V
                                       WHERE (V.taxi = T.matricula)
                                         AND (V.motorista = M.nif)
                                         AND (TO_CHAR(V.inicio,'HH24') BETWEEN '06'
                                                                           AND '11')))
 ORDER BY euros_por_minuto DESC, T.matricula ASC;      
 
--  4. NIF e nome dos motoristas que faturaram mais euros em viagens em cada ano, separada-
-- mente para motoristas masculinos e femininos, devendo o g�nero dos motoristas e o total
-- faturado em cada ano tamb�m aparecer no resultado. Considere que o valor de fatura��o
-- de uma viagem corresponde ao pre�o por minuto do t�xi, em euros, a multiplicar pelos
-- minutos que passaram entre o in�cio e o fim da viagem. A ordena��o do resultado deve ser
-- pelo ano de forma descendente e pelo g�nero dos motoristas de forma ascendente. No caso
-- de haver mais do que um(a) motorista com o mesmo m�ximo de fatura��o num ano, de-
-- vem ser mostrados todos esses motoristas. Nota: para efeitos de determina��o do ano de
-- fatura��o, deve ser considerada a data de fim de cada viagem (mesmo que a viagem tenha
-- come�ado no ano anterior). Nota: por conveni�ncia, est� dispon�vel a fun��o minutos_-
-- que_passaram, que calcula quantos minutos passaram entre duas datas.1
-- Variantes com menor cota��o: a) mostrar o total faturado em viagens por cada motorista
-- em cada ano, sem verificar se foram os/as que mais faturaram; e b) sem a distin��o entre
-- motoristas femininos e masculinos.

SELECT M1.nif, M1.nome, M1.genero, TO_NUMBER(TO_CHAR(V1.fim,'YYYY')) AS ano,
         SUM(T1.eurosminuto * minutos_que_passaram(V1.inicio, V1.fim)) AS faturamento
  FROM motorista M1, taxi T1, viagem V1
 WHERE (M1.nif = V1.motorista)
   AND (V1.taxi = T1.matricula)
   AND ((M1.genero = 'M') 
        AND ((SELECT SUM(T2.eurosminuto * minutos_que_passaram(V2.inicio, V2.fim))
                 FROM viagem V2, taxi T2
                WHERE (V2.motorista = M1.nif)
                  AND (V2.taxi = T2.matricula)
                  AND (TO_CHAR(V2.fim, 'YYYY') = TO_CHAR(V1.fim, 'YYYY'))
                GROUP BY M1.nif, M1.nome) = 
              (SELECT MAX (SUM(T3.eurosminuto * minutos_que_passaram(V3.inicio, V3.fim)))
                 FROM viagem V3, taxi T3, motorista M3
                WHERE (V3.motorista = M3.nif)
                  AND (V3.taxi = T3.matricula)
                  AND (M3.genero = 'M')
                  AND (TO_CHAR(V3.fim, 'YYYY') = TO_CHAR(V1.fim, 'YYYY'))
                GROUP BY M3.nif)) 
        OR 
        ((M1.genero = 'F') 
         AND ((SELECT SUM(T4.eurosminuto * minutos_que_passaram(V4.inicio, V4.fim))
                 FROM viagem V4, taxi T4
                WHERE (V4.motorista = M1.nif)
                  AND (V4.taxi = T4.matricula)
                  AND (TO_CHAR(V4.fim, 'YYYY') = TO_CHAR(V1.fim, 'YYYY'))
                GROUP BY M1.nif, M1.nome) = 
              (SELECT MAX (SUM(T5.eurosminuto * minutos_que_passaram(V5.inicio, V5.fim)))
                 FROM viagem V5, taxi T5, motorista M5
                WHERE (V5.motorista = M5.nif)
                  AND (V5.taxi = T5.matricula)
                  AND (M5.genero = 'F')
                  AND (TO_CHAR(V5.fim, 'YYYY') = TO_CHAR(V1.fim, 'YYYY'))
                GROUP BY M5.nif))))
  GROUP BY M1.nif, M1.nome, M1.genero, TO_NUMBER(TO_CHAR(V1.fim, 'YYYY'))
  ORDER BY ano DESC, M1.genero ASC;

