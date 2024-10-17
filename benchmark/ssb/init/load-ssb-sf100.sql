CREATE TABLE part
(
    p_partkey   UINTEGER,
    p_name      VARCHAR,
    p_mfgr      VARCHAR,
    p_category  VARCHAR,
    p_brand1    VARCHAR,
    p_color     VARCHAR,
    p_type      VARCHAR,
    p_size      UTINYINT,
    p_container VARCHAR,
    PRIMARY KEY (p_partkey)
);

CREATE TABLE supplier
(
    s_suppkey UINTEGER,
    s_name    VARCHAR,
    s_address VARCHAR,
    s_city    VARCHAR,
    s_nation  VARCHAR,
    s_region  VARCHAR,
    s_phone   VARCHAR,
    PRIMARY KEY (s_suppkey)
);

CREATE TABLE customer
(
    c_custkey    UINTEGER,
    c_name       VARCHAR,
    c_address    VARCHAR,
    c_city       VARCHAR,
    c_nation     VARCHAR,
    c_region     VARCHAR,
    c_phone      VARCHAR,
    c_mktsegment VARCHAR,
    PRIMARY KEY (c_custkey)
);

CREATE TABLE date
(
    d_datekey          DATE,
    d_date             VARCHAR,
    d_dayofweek        VARCHAR,
    d_month            VARCHAR,
    d_year             USMALLINT,
    d_yearmonthnum     UINTEGER,
    d_yearmonth        VARCHAR,
    d_daynuminweek     UTINYINT,
    d_daynuminmonth    UTINYINT,
    d_daynuminyear     USMALLINT,
    d_monthnuminyear   UTINYINT,
    d_weeknuminyear    UTINYINT,
    d_sellingseason    VARCHAR,
    d_lastdayinweekfl  BOOLEAN,
    d_lastdayinmonthfl BOOLEAN,
    d_holidayfl        BOOLEAN,
    d_weekdayfl        BOOLEAN,
    PRIMARY KEY (d_datekey)
);

CREATE TABLE lineorder
(
    lo_orderkey      UINTEGER,
    lo_linenumber    UTINYINT,
    lo_custkey       UINTEGER,
    lo_partkey       UINTEGER,
    lo_suppkey       UINTEGER,
    lo_orderdate     DATE,
    lo_orderpriority VARCHAR,
    lo_shippriority  VARCHAR,
    lo_quantity      UTINYINT,
    lo_extendedprice UINTEGER,
    lo_ordtotalprice UINTEGER,
    lo_discount      UTINYINT,
    lo_revenue       UINTEGER,
    lo_supplycost    UINTEGER,
    lo_tax           UTINYINT,
    lo_commitdate    DATE,
    lo_shipmode      VARCHAR,
    PRIMARY KEY (lo_orderkey, lo_linenumber)
);

COPY part FROM 'benchmark/ssb/data/sf100/part.tbl';
COPY supplier FROM 'benchmark/ssb/data/sf100/supplier.tbl';
COPY customer FROM 'benchmark/ssb/data/sf100/customer.tbl';
COPY date FROM 'benchmark/ssb/data/sf100/date.tbl';
COPY lineorder FROM 'benchmark/ssb/data/sf100/lineorder.tbl';
