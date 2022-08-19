/*
Задача 2
Необходимо найти всех клиентов, чей торговый оборот в текущем месяце увеличился более, чем
на 10%, по сравнению с предыдущим месяцем, и вывести коммуникации, которые они получали в
течение прошлых 30-ти дней.
*/
/*рассматривается календарный месяц*/

/*Итоговый запрос*/
SELECT current_mounth.ow_id, coalesce(cell.cell_pk, 0) AS cell_pk
FROM
    (
        SELECT ow_id, SUM(pos) AS spended
        FROM cash
        WHERE EXTRACT(YEAR FROM cash_dt) = EXTRACT(YEAR FROM CURRENT_DATE)
            AND EXTRACT(MONTH FROM cash_dt) = EXTRACT(MONTH FROM CURRENT_DATE)
        GROUP BY ow_id
    ) AS current_mounth
    LEFT JOIN
    (
        SELECT ow_id, SUM(pos) AS spended
        FROM cash
        WHERE EXTRACT(YEAR FROM cash_dt) = EXTRACT(YEAR FROM CURRENT_DATE  - INTERVAL '1 month')
            AND EXTRACT(MONTH FROM cash_dt) = EXTRACT(MONTH FROM CURRENT_DATE  - INTERVAL '1 month')
        GROUP BY ow_id
    ) AS previous_mounth
        ON current_mounth.ow_id = previous_mounth.ow_id
    LEFT JOIN cell
        ON cell.sent_date > CURRENT_DATE - 30
            AND current_mounth.ow_id = cell.ow_id
WHERE current_mounth.spended > coalesce(previous_mounth.spended, 0) * 1.1;

/*оборот в текущем месяце*/
SELECT ow_id, SUM(pos) AS spended
FROM cash
WHERE EXTRACT(YEAR FROM cash_dt) = EXTRACT(YEAR FROM CURRENT_DATE)
    AND EXTRACT(MONTH FROM cash_dt) = EXTRACT(MONTH FROM CURRENT_DATE)
GROUP BY ow_id;

/*оборот в прошлом месяце*/
SELECT ow_id, SUM(pos) AS spended
FROM cash
WHERE EXTRACT(YEAR FROM cash_dt) = EXTRACT(YEAR FROM CURRENT_DATE  - INTERVAL '1 month')
  AND EXTRACT(MONTH FROM cash_dt) = EXTRACT(MONTH FROM CURRENT_DATE  - INTERVAL '1 month')
GROUP BY ow_id;

/*
Клиенты, чей торговый оборот в текущем месяце увеличился более, чем на 10%, по сравнению с предыдущим месяцем
*/
SELECT current_mounth.ow_id, current_mounth.spended, previous_mounth.spended
FROM
    (
        SELECT ow_id, SUM(pos) AS spended
        FROM cash
        WHERE EXTRACT(YEAR FROM cash_dt) = EXTRACT(YEAR FROM CURRENT_DATE)
            AND EXTRACT(MONTH FROM cash_dt) = EXTRACT(MONTH FROM CURRENT_DATE)
        GROUP BY ow_id
    ) AS current_mounth
LEFT JOIN
    (
        SELECT ow_id, SUM(pos) AS spended
        FROM cash
        WHERE EXTRACT(YEAR FROM cash_dt) = EXTRACT(YEAR FROM CURRENT_DATE  - INTERVAL '1 month')
          AND EXTRACT(MONTH FROM cash_dt) = EXTRACT(MONTH FROM CURRENT_DATE  - INTERVAL '1 month')
        GROUP BY ow_id
    ) AS previous_mounth
    ON current_mounth.ow_id = previous_mounth.ow_id
WHERE current_mounth.spended > coalesce(previous_mounth.spended, 0) * 1.1;

/*Вывод коммуникаций, не старше 30 дней*/
SELECT *
FROM cell
WHERE sent_date > CURRENT_DATE - 30;