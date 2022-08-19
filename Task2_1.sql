/*
Задача 1
Составить выборку для отправки email-а по партнеру 1111 клиентам, которые не получали
коммуникации по данному партнеру за прошлую неделю ни по одному из каналов. Так же
необходимо разделить клиентов на три сегмента, исходя из их трат у этого партнера за последние
30 дней:
1 Клиент не совершал покупки у партнера.
2 Клиент совершил покупки на сумму до 1000 р(включительно).
3 Клиент совершил покупки на сумму более 1000 р.
*/

SELECT ow.ow_id AS Клиент,
       CASE
           WHEN SUM(pos) IS NULL THEN 1
           WHEN SUM(pos) <= 1000 THEN 2
           ELSE 3
        END AS Сегмент
FROM
    ow
    LEFT JOIN cash
        ON ow.ow_id = cash.ow_id
        AND cash.partner_id = 1111
        AND cash.cash_dt >= CURRENT_DATE - 30
WHERE ow.email_flg = 1
    AND ow.ow_id NOT IN(
        SELECT DISTINCT ow_id
        FROM cell
        WHERE CURRENT_DATE - sent_date < 7 AND partner_id = 1111
    )
    AND (
        ow.ow_id IN (SELECT DISTINCT ow_id
            FROM cell
            WHERE partner_id = 1111)
        OR
        ow.ow_id IN (SELECT DISTINCT ow_id
            FROM cash
            WHERE partner_id = 1111)
    )
GROUP BY ow.ow_id;