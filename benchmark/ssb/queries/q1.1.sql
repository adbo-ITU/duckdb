COPY part FROM '../ads2024-ssb-dbgen/part.tbl';
COPY supplier FROM '../ads2024-ssb-dbgen/supplier.tbl';
COPY customer FROM '../ads2024-ssb-dbgen/customer.tbl';
COPY date FROM '../ads2024-ssb-dbgen/date.tbl';
COPY lineorder FROM '../ads2024-ssb-dbgen/lineorder.tbl';

SELECT SUM(lo_extendedprice * lo_discount) AS revenue
FROM lineorder, date
WHERE lo_orderdate = d_datekey
  AND d_year = 1993
  AND lo_discount BETWEEN 1 AND 3
  AND lo_quantity < 25;
