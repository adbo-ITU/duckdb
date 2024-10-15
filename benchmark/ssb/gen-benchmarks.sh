#!/bin/bash

# Assumes that you have the SSB data in the `data` directory and the queries in the `queries` directory
#
# For example, before running this file, you have these files:
# ├── queries
# │   ├── q1.1.sql
# │   ├── q1.2.sql
# │   ├── q4.2.sql
# │   └── ...
# ├── data
# │   ├── sf1
# │   │   ├── customer.tbl
# │   │   ├── date.tbl
# │   │   ├── lineorder.tbl
# │   │   ├── part.tbl
# │   │   └── supplier.tbl
# │   └── sf10
# │       ├── customer.tbl
# │       └── ...
# └── ssb.benchmark.in
#
# This script will then generate all the benchmark files for the SSB benchmark, i.e.:
# ├── benchmarks
# │   ├── sf1
# │   │   ├── q1.1.benchmark
# │   │   ├── q1.2.benchmark
# │   │   ├── q1.3.benchmark
# │   │   └── ...
# │   └── sf10
# │       ├── q1.1.benchmark
# │       ├── q1.2.benchmark
# │       ├── q1.3.benchmark
# │       └── ...
# └── init
#     ├── load-ssb-sf1.sql
#     └── load-ssb-sf10.sql

for sf_dir in ./benchmark/ssb/data/*; do
  sf_dir_name=$(basename $sf_dir)
  scaling_factor="${sf_dir_name#"sf"}"

  for query_file in ./benchmark/ssb/queries/*.sql; do
    query_number=$(echo $query_file | awk -F'[/q.]' '{print $(NF-3) "." $(NF-2)}')

    echo "Generating query $query_number for scaling factor $scaling_factor..."

    bench_file="# name: benchmark/ssb/benchmarks/sf$scaling_factor/q$query_number.benchmark
# description: Run query $query_number from the SSB benchmark
# group: [ssb]

template benchmark/ssb/ssb.benchmark.in
QUERY_NUMBER=$query_number
SCALING_FACTOR=$scaling_factor"

    mkdir -p "./benchmark/ssb/benchmarks/sf$scaling_factor"
    echo "$bench_file" > "./benchmark/ssb/benchmarks/sf$scaling_factor/q$query_number.benchmark"
  done

  echo "Generating loader file for scaling factor $scaling_factor..."

  load_file="CREATE TABLE part
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

COPY part FROM 'benchmark/ssb/data/sf$scaling_factor/part.tbl';
COPY supplier FROM 'benchmark/ssb/data/sf$scaling_factor/supplier.tbl';
COPY customer FROM 'benchmark/ssb/data/sf$scaling_factor/customer.tbl';
COPY date FROM 'benchmark/ssb/data/sf$scaling_factor/date.tbl';
COPY lineorder FROM 'benchmark/ssb/data/sf$scaling_factor/lineorder.tbl';"

    mkdir -p "./benchmark/ssb/init"
    echo "$load_file" > "./benchmark/ssb/init/load-ssb-sf$scaling_factor.sql"
done
