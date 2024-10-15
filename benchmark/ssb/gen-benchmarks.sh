#!/bin/bash

for sf_dir in ./benchmark/ssb/data/*; do
  sf_dir_name=$(basename $sf_dir)
  scaling_factor="${sf_dir_name#"sf"}"

  for query_file in ./benchmark/ssb/queries/*.sql; do
    query_number=$(echo $query_file | awk -F'[/q.]' '{print $(NF-3) "." $(NF-2)}')

    bench_file="# name: benchmark/ssb/benchmarks/sf$scaling_factor/q$query_number.benchmark
# description: Run query $query_number from the SSB benchmark
# group: [ssb]

template benchmark/ssb/ssb.benchmark.in
QUERY_NUMBER=$query_number
SCALING_FACTOR=$scaling_factor"

    mkdir -p "./benchmark/ssb/benchmarks/sf$scaling_factor"
    echo "$bench_file" > "./benchmark/ssb/benchmarks/sf$scaling_factor/q$query_number.benchmark"
  done
done
