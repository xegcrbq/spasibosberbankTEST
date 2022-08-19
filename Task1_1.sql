/*
Задача 1
Вывести всех клиентов с их наибольшим количеством бонусов, полученных за одну транзакцию
после участия в акции партнера 1111, в течение прошлых 30-ти дней при условии, что клиент
совершил более 5 транзакций за это время, но не совершал покупок у партнера 4444, и получил
хотя бы одну коммуникацию от данного партнера(1111) за прошедшие 30 дней.
Задачу необходимо выполнить одним запросом.
*/

/*Вариант 1, выводим всех клиентов, которые удовлетворяют условиям*/
SELECT cash.ow_id,
    MAX(CASE WHEN cash.partner_id = 1111 THEN cash.pos::DECIMAL * (promotion.prcnt_value::DECIMAL / 100) ELSE 0 END) AS Наибольшее_количество_бонусов_за_1
    /*Вывести с наибольшим количеством бонусов, полученных за одну транзакцию после участия в акции партнера 1111*/
FROM
    cash
    INNER JOIN cell
        ON cash.ow_id = cell.ow_id
            AND cell.partner_id = 1111 /*получил хотя бы одну коммуникацию от данного партнера(1111)*/
            AND CURRENT_DATE - cell.sent_date < 30 /*получил хотя бы одну коммуникацию за прошедшие 30 дней*/
    LEFT JOIN promotion
        ON promotion.partner_id = cash.partner_id /*после участия в акции партнера 1111*/
            AND promotion.active_flg = 1 /*Делаем допущение, что пользователи получают бонусы только по текущей активной акции*/
/*Если требуется пройтись по всем акциям, в том числе по неативным, строку выше следует удалить*/
WHERE CURRENT_DATE - cash.cash_dt < 30 /*в течение прошлых 30-ти дней*/
GROUP BY cash.ow_id, cell_pk /*INNER JOIN cell может "удвоить" число значений, если было 2 коммутации для 1го пользователя за последний месяц*/
HAVING COUNT(*) > 5 /*клиент совершил более 5 транзакций за это время*/
    AND SUM(CASE WHEN cash.partner_id = 4444 THEN 1 ELSE 0 END) = 0;/*не совершал покупок у партнера 4444*/


/*Вариант 2, выводим ВСЕХ клиентов, бонусы считаем только для удовлетворяющих условиям*/
SELECT cash.ow_id,/*Вывести всех клиентов*/
    MAX(CASE WHEN cash.partner_id = 1111
        AND cash.ow_id IN( /*все клиенты совершившие более 5 транзакций, не совершавшие покупок у партнёра 4444 за последние 30 дней */
            SELECT cash.ow_id
            FROM cash
            WHERE CURRENT_DATE - cash.cash_dt < 30
            GROUP BY cash.ow_id
            HAVING COUNT(*) > 5
                AND SUM(CASE WHEN cash.partner_id = 4444 THEN 1 ELSE 0 END) = 0
        )
        AND cash.ow_id IN ( /*Все клиенты, кто получил хотя бы одну коммуникацию от данного партнера(1111)*/
            SELECT DISTINCT cell.ow_id
            FROM cell
            WHERE  cell.partner_id = 1111
                AND CURRENT_DATE - cell.sent_date < 30
        )
        THEN cash.pos::DECIMAL * (promotion.prcnt_value::DECIMAL / 100) ELSE 0 END) AS Наибольшее_количество_бонусов_за_1
    /*Вывести с наибольшим количеством бонусов, полученных за одну транзакцию после участия в акции партнера 1111*/
FROM
    cash
    LEFT JOIN cell/*Вывести всех клиентов*/
        ON cash.ow_id = cell.ow_id
            AND cell.partner_id = 1111 /*получил хотя бы одну коммуникацию от данного партнера(1111)*/
            AND CURRENT_DATE - cell.sent_date < 30 /*получил хотя бы одну коммуникацию за прошедшие 30 дней*/
    LEFT JOIN promotion
        ON promotion.partner_id = cash.partner_id /*после участия в акции партнера 1111*/
            AND promotion.active_flg = 1 /*Делаем допущение, что пользователи получают бонусы только по текущей активной акции*/
GROUP BY cash.ow_id;/*не совершал покупок у партнера 4444*/

SELECT cash.ow_id /*все клиенты совершившие более 5 транзакций, не совершавшие покупок у партнёра 4444 за последние 30 дней */
FROM cash
WHERE CURRENT_DATE - cash.cash_dt < 30
GROUP BY cash.ow_id
HAVING COUNT(*) > 5
    AND SUM(CASE WHEN cash.partner_id = 4444 THEN 1 ELSE 0 END) = 0;

SELECT DISTINCT cell.ow_id /*Все клиенты, кто получил хотя бы одну коммуникацию от данного партнера(1111)*/
FROM cell
WHERE  cell.partner_id = 1111
    AND CURRENT_DATE - cell.sent_date < 30;
