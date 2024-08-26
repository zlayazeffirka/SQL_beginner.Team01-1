WITH
	volume_money AS
	(SELECT user_id, SUM(money) AS volume, type, currency_id
	 FROM balance
	 GROUP BY user_id, type, currency_id),
	last_rate AS
	(SELECT DISTINCT ON (id) id, name, rate_to_usd
     FROM currency
     ORDER BY id, updated DESC)

SELECT COALESCE(us.name, 'not defined') AS name,
       COALESCE(us.lastname, 'not defined') AS lastname,
	   volume_money.type,
	   volume,
	   COALESCE(last_rate.name, 'not defined') AS currency_name,
	   COALESCE(last_rate.rate_to_usd, 1) AS last_rate_to_usd,
	   (volume * COALESCE(last_rate.rate_to_usd, 1)) AS total_volume_in_usd
FROM "user" AS us
RIGHT JOIN volume_money ON us.id = volume_money.user_id
LEFT JOIN last_rate ON volume_money.currency_id = last_rate.id
ORDER BY name DESC, lastname, type;