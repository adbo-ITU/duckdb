#include "ssb_appender.hpp"

#include "../ssbgen/include/driver.hpp"
#include "duckdb.hpp"
#ifndef DUCKDB_AMALGAMATION
#include "duckdb/catalog/catalog.hpp"
#include "duckdb/catalog/catalog_entry/table_catalog_entry.hpp"
#include "duckdb/common/exception.hpp"
#include "duckdb/common/types/date.hpp"
#include "duckdb/main/appender.hpp"
#include "duckdb/parser/column_definition.hpp"
#include "duckdb/parser/constraints/not_null_constraint.hpp"
#include "duckdb/parser/parsed_data/create_table_info.hpp"
#ifndef DUCKDB_NO_THREADS
#include "duckdb/common/thread.hpp"
#endif
#endif

namespace ssb {
SSBTableDataGenerator::SSBTableDataGenerator(duckdb::ClientContext &context, SSBGenParameters &parameters)
    : context {context}, parameters {parameters},
      append_containers {duckdb::unique_ptr<ssb_append_container[]>(new ssb_append_container[NUMBER_OF_TABLES])} {

	uint64_t flush_count = duckdb::BaseAppender::DEFAULT_FLUSH_COUNT;
	memset(append_containers.get(), 0, sizeof(ssb_append_container) * NUMBER_OF_TABLES);

	for (size_t i = 0; i < NUMBER_OF_TABLES; i++) {

		if (parameters.tables[i]) {

			auto &tbl_catalog = *parameters.tables[i];
			append_containers[i].appender =
			    duckdb::make_uniq<duckdb::InternalAppender>(context, tbl_catalog, flush_count);
		}
	}
}

ssb_appender *SSBTableDataGenerator::GetAppender() {
	ssb_appender *append_container = new ssb_appender();

	auto customer_appender = &append_containers[translate_dbgen_table_index(CUST)];
	append_container->pr_cust = [customer_appender](customer_t *record, int mode) -> int {
		append_customer(record, customer_appender);
		return 0;
	};

	auto date_appender = &append_containers[translate_dbgen_table_index(SSB_DATE)];
	append_container->pr_date = [date_appender](ssb_date_t *record, int mode) -> int {
		append_date(record, date_appender);
		return 0;
	};

	auto lineorder_appender = &append_containers[translate_dbgen_table_index(LINE)];
	append_container->pr_line = [lineorder_appender](order_t *record, int mode) -> int {
		append_line_order(record, lineorder_appender);
		return 0;
	};

	auto part_appender = &append_containers[translate_dbgen_table_index(PART)];
	append_container->pr_part = [part_appender](part_t *record, int mode) -> int {
		append_part(record, part_appender);
		return 0;
	};

	auto supplier_appender = &append_containers[translate_dbgen_table_index(SUPP)];
	append_container->pr_supp = [supplier_appender](supplier_t *record, int mode) -> int {
		append_supplier(record, supplier_appender);
		return 0;
	};

	return append_container;
}

// Generates and loads data into the tables
void SSBTableDataGenerator::GenerateData() {
	ssb_appender *appender = GetAppender();

	// Generate the data
	int status = gen_main(parameters.scale_factor, appender);
	delete appender; // delete the appender to free up memory

	if (status != 0) {
		throw duckdb::InternalException("Failed to generate data for SSB tables");
	}
}
} // namespace ssb