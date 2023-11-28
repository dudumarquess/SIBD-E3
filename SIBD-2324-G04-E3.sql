-- ----------------------------------------------------------------------
-- SIBD 2023-2024.
-- Etapa 2 do projeto, Grupo n? 04.
-- Eduardo Marques 59798, TP 14;
-- Gabriel Nakamura 59842, TP 14;
-- Gonçalo Silveira 59866, TP 12;
-- Bárbara Rosa 56287, TP 13.
-- ----------------------------------------------------------------------
-- Contribuições: Fizemos o trabalho em conjunto, sendo assim, todos os 
-- participantes têm todos a mesma percentagem de contribuição, 25% cada.

-- ----------------------------------------------------------------------
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';
-- ----------------------------------------------------------------------
-- Motorista (nif, nome, genero, nascimento, localidade)
--      Taxi (matricula, ano, marca, conforto, eurosminuto)
--    Viagem (motorista, inicio, fim, taxi, passageiros)
-- ----------------------------------------------------------------------
-- 1. NIF, nome, e idade das motoristas femininas com apelido Afonso, que conduziram em vi-
-- agens com três ou mais passageiros, em táxis com conforto luxuoso, durante o ano de
-- 2023, incluindo o caso particular da noite da passagem de ano, em que uma viagem pode
-- ter começado em 2022 e terminado já em 2023. A matrícula e a marca do(s) táxi(s) tam-
-- bém devem ser mostradas. O resultado deve vir ordenado de forma ascendente pela idade
-- e nome das motoristas, e de forma descendente pela marca e matrícula dos táxis. Nota: a
-- extração do ano a partir de uma data pode ser feita usando TO_CHAR(data, 'YYYY').
-- Variantes com menor cotação: a) sem o cálculo da idade das motoristas; e b) sem a verifi-
-- cação do caso da noite da passagem de ano.
 
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
-- 2022 (não deve ser considerada a data de fim das viagens), ou não conduziram táxis da
-- marca Lancia ou conduziram táxis dessa marca em até duas viagens. Adicionalmente, os
-- motoristas resultantes não podem ter conduzido táxis comprados antes de 2000, indepen-
-- dentemente do ano das viagens. O resultado deve vir ordenado pelo nome dos motoristas
-- de forma ascendente e pelo NIF de forma descendente.
-- Variantes com menor cotação: a) sem a verificação dos motoristas nunca terem conduzido
-- táxis comprados antes de 2000; e b) sem a verificação do número de viagens que conduzi-
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
                      
-- -------------------------------------------------------------------------
-- 3.Todos os dados dos táxis da marca Lexus, com preço por minuto acima da média dos pre-
-- ços por minuto de todos os táxis (independentemente da marca), e que tenham sido algu-
-- ma vez conduzidos por todos os motoristas de Lisboa na parte da manhã dos dias, mais
-- precisamente entre as 6h00 e as 11h59. Para simplificar, consideram-se apenas as viagens
-- iniciadas de manhã (a data de fim das viagens deve ser ignorada). O resultado deve vir
-- ordenado pelo preço por minuto dos táxis de forma descendente e pela matrícula dos táxis
-- de forma ascendente. Nota: a extração da hora do dia a partir de uma data pode ser feita
-- usando TO_CHAR(data, 'HH24').
-- Variantes com menor cotação: a) sem a verificação do preço por minuto dos táxis ser su-
-- perior à média dos preços por minuto de todos os táxis; e b) sem as verificações da locali-
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
-- mente para motoristas masculinos e femininos, devendo o género dos motoristas e o total
-- faturado em cada ano também aparecer no resultado. Considere que o valor de faturação
-- de uma viagem corresponde ao preço por minuto do táxi, em euros, a multiplicar pelos
-- minutos que passaram entre o início e o fim da viagem. A ordenação do resultado deve ser
-- pelo ano de forma descendente e pelo género dos motoristas de forma ascendente. No caso
-- de haver mais do que um(a) motorista com o mesmo máximo de faturação num ano, de-
-- vem ser mostrados todos esses motoristas. Nota: para efeitos de determinação do ano de
-- faturação, deve ser considerada a data de fim de cada viagem (mesmo que a viagem tenha
-- começado no ano anterior). Nota: por conveniência, está disponível a função minutos_-
-- que_passaram, que calcula quantos minutos passaram entre duas datas.1
-- Variantes com menor cotação: a) mostrar o total faturado em viagens por cada motorista
-- em cada ano, sem verificar se foram os/as que mais faturaram; e b) sem a distinção entre
-- motoristas femininos e masculinos.

SELECT M1.nif, M1.nome, M1.genero, TO_NUMBER(TO_CHAR(V1.fim,'YYYY')) AS ano,
         SUM(T1.eurosminuto * minutos_que_passaram(V1.inicio, V1.fim)) AS faturamento
  FROM motorista M1, taxi T1, viagem V1
 WHERE (M1.nif = V1.motorista)
   AND (V1.taxi = T1.matricula)
   AND (((M1.genero = 'M') 
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
                GROUP BY M5.nif)))))
  GROUP BY M1.nif, M1.nome, M1.genero, TO_NUMBER(TO_CHAR(V1.fim, 'YYYY'))
  ORDER BY ano DESC, M1.genero ASC;

