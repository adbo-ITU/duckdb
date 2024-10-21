#!/bin/bash

# Assumes that you have the SSB data in the `data` directory and the queries in the `queries` directory
#
# For example, before running this file, you have these files:
# ├── queries
# │   ├── q1.1.sql
# │   ├── q1.2.sql
# │   ├── q4.2.sql
# │   └── ...
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

threads=(1 4 8)
sfs=(1 10 100)

for thread in "${threads[@]}"; do
  echo "Generating queries for $thread threads..."

  mkdir -p "./benchmark/ssb/queries/threads-$thread"

  for query_file in ./benchmark/ssb/queries/*.sql; do
      filename=$(basename $query_file)

      echo "pragma threads=$thread;" > "./benchmark/ssb/queries/threads-$thread/$filename"
      cat $query_file >> "./benchmark/ssb/queries/threads-$thread/$filename"
  done
done

for scaling_factor in "${sfs[@]}"; do
  for query_file in ./benchmark/ssb/queries/*.sql; do
    query_number=$(echo $query_file | awk -F'[/q.]' '{print $(NF-3) "." $(NF-2)}')

    for thread in "${threads[@]}"; do
      echo "Generating benchmark $query_number for scaling factor $scaling_factor with $thread threads..."

      bench_file="# name: benchmark/ssb/benchmarks/sf$scaling_factor/q$query_number-t$thread.benchmark
# description: Run query $query_number from the SSB benchmark with scale factor $scaling_factor and $thread threads
# group: [ssb]

template benchmark/ssb/ssb.benchmark.in
QUERY_NUMBER=$query_number
SCALING_FACTOR=$scaling_factor
THREADS=$thread"

      mkdir -p "./benchmark/ssb/benchmarks/sf$scaling_factor"
      echo "$bench_file" > "./benchmark/ssb/benchmarks/sf$scaling_factor/q$query_number-t$thread.benchmark"
    done
  done
done
