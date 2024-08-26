WITH last_rate AS
		(SELECT COALESCE("user".name, 'not defined') AS name,
            	COALESCE("user".lastname, 'not defined') AS lastname,
            	c.name AS currency_name,
           		balance.money,
				balance.currency_id,
				COALESCE(
	                (
	                    SELECT rate_to_usd
	                    FROM currency
	                    WHERE balance.currency_id = currency.id
	                        AND currency.updated < balance.updated
	                    ORDER BY currency.updated desc
	                    LIMIT 1
	                ), (
	                    SELECT rate_to_usd
	                    FROM currency
	                    WHERE balance.currency_id = currency.id
	                        AND currency.updated > balance.updated
	                    ORDER BY currency.updated asc
	                    LIMIT 1
	                )
	            ) AS rate_to_usd	
	     FROM balance
		 	JOIN (
				SELECT currency.id,
                    currency.name
                FROM currency
                GROUP BY currency.id, currency.name) AS c ON c.id = balance.currency_id
            LEFT JOIN "user" ON balance.user_id = "user".id)

SELECT  name,
		lastname,
		currency_name,
		money * rate_to_usd AS currency_in_usd
FROM last_rate
ORDER BY last_rate.name DESC, last_rate.lastname, last_rate.currency_name;
