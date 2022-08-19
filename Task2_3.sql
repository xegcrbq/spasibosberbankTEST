/*
Задача 3
Необходимо помесячно:
1)Количество отправленных коммуникаций, количество доставленных коммуникаций,
количество открытых коммуникаций, количество коммуникаций с переходами по ссылке.
2)Среднее количество отправленных коммуникаций на клиента, среднее количество
партнеров, по которым клиент получил коммуникации, среднее количество каналов, по
которым клиент получил коммуникации
Необходимо посчитать показатели выше 1-3 запросами. В результате выполнения запросов
должна сформироваться таблица следующего вида:
*/

/*группируем результат по месяцам*/
SELECT Месяц,
    SUM(sent_count) AS Количество_отправленных_коммуникаций,
    SUM(delivered_count) AS Количество_доставленных_коммуникаций,
    SUM(opened_count) AS Количество_открытых_коммуникаций,
    SUM(clicked_count) AS Количество_коммуникаций_с_переходами_по_ссылке,
    AVG(sent_count) AS Среднее_количество_отправленных_коммуникаций_на_клиента,
    AVG(partner_count) AS среднее_количество_партнеров_по_которым_клиент_получил_коммун,
    AVG(channel_nm_count) AS среднее_количество_каналов_по_которым_клиент_получил_коммун
FROM
    (
        SELECT to_char(sent_date, 'Month') AS Месяц,
           SUM(sent) AS sent_count, SUM(delivered) AS delivered_count,
           SUM(opened) AS opened_count, SUM(clicked) AS clicked_count,
           COUNT(DISTINCT CASE WHEN delivered = 1 THEN partner_id END) AS partner_count,
           COUNT(DISTINCT CASE WHEN delivered = 1 THEN channel_nm END) AS channel_nm_count
        FROM cell
        GROUP BY Месяц, ow_id
    ) AS grouped_cell
GROUP BY Месяц;