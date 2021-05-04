SELECT
	j.journal_id, j.sale_ID ,j.action_type,
	s.sale_ID, s.officeCode, s.salesKey, s.destination, s.saleDate, s.serviceClass,
	s.serviceNumber, s.serviceTime, s.origin, s.serviceDate, s.category, s.price, s.saleTime, s.discount
FROM classicmodels.gfaSales_journal j
LEFT JOIN classicmodels.gfaSales s ON s.sale_ID = j.sale_ID
WHERE j.journal_id > :sql_last_value
	AND j.action_time < NOW()
ORDER BY j.journal_id