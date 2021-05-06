SELECT s.sale_id, s.officeCode, s.salesAgent, s.destination, s.saleDate, s.serviceClass, s.serviceNumber, s.serviceTime, s.origin, s.serviceDate, s.category, s.price, s.saleTime, s.discount,
	o.longitude as destinationLongitude, o.latitude as destinationLatitude
FROM classicmodels.gfasales s
LEFT JOIN classicmodels.offices o ON s.destination= o.officeCode