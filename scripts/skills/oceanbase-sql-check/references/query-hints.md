# OceanBase 4.4.2 Query Hints — Complete Official-Reference Guide

## Scope and source

This guide inventories the query and DML hints documented for **OceanBase Database 4.4.2**. It covers the complete dedicated SQL Reference hint chapter, scans all 1,172 English SQL Reference Markdown pages for hint usage, and cross-scans all 5,995 English documentation pages for additional named hint evidence.

- Official repository: [https://github.com/oceanbase/oceanbase-doc](https://github.com/oceanbase/oceanbase-doc)
- Branch: `V4.4.2`
- Pinned commit: [`017c8d35a015afa04ce1e1ce4b95675e3223c878`](https://github.com/oceanbase/oceanbase-doc/tree/017c8d35a015afa04ce1e1ce4b95675e3223c878)
- Assessment: static documentation review, not live execution testing.

## Inventory summary

| Measure | Count |
|---|---:|
| Dedicated hint-chapter pages | 18 |
| Dedicated hint sections | 137 |
| Unique names in the dedicated chapter | 134 |
| Additional officially evidenced entries | 3 (`UNION_MERGE`, `TRACE_LOG`, `JOIN_ORDER`) |
| **Total unique entries in this guide** | **137** |
| Dedicated-chapter hints with explicit MySQL-mode evidence | 19 |

### Mode-accounting rule

The dedicated hint chapter is located under **Oracle mode**. The MySQL-mode annotation page describes comments but does not enumerate optimizer hints. MySQL `SELECT` documentation links its `hint_options` grammar to the shared optimizer-hint guide. Accordingly, this guide does not silently label every Oracle-chapter hint as MySQL-compatible: an entry receives MySQL evidence only when the shared guide or a MySQL-mode SQL Reference page explicitly contains that hint. “Not separately enumerated” is not a claim of non-support.

`JOIN_ORDER` is example-only evidence. `BEGIN_OUTLINE_DATA` and `END_OUTLINE_DATA` are outline-data structural markers, not independent optimizer hints. Placeholder tokens are excluded in Appendix D.

## General usage rules

- A hint uses special comment syntax such as `/*+ INDEX(t idx_t) */` immediately after an applicable statement keyword.
- Hint arguments are **not comma-separated in the same way as ordinary function arguments**. Follow each entry’s exact syntax; for example, OceanBase documents `INDEX(table_name index_name)` with a space.
- Hints influence optimization but do not change SQL semantics. An unrecognized or malformed hint can be ignored rather than raising an error.
- A documented hint does not guarantee a particular physical operator in every query. Preconditions, query shape, indexes, statistics, and optimizer decisions still matter.
- Query-block names and `@qb_name` arguments provide precise control. See Appendix C.
- If a client strips comments, hints may never reach the server. The shared guide specifically notes the MySQL C client `-c` requirement.

## Table of contents

- **Global > Optimizer statistics**
  - [`GATHER_OPTIMIZER_STATISTICS`](#gather_optimizer_statistics)
  - [`NO_GATHER_OPTIMIZER_STATISTICS`](#no_gather_optimizer_statistics)
- **Global > Other**
  - [`APPEND`](#append)
  - [`CURSOR_SHARING_EXACT`](#cursor_sharing_exact)
  - [`DIRECT`](#direct)
  - [`DISABLE_PARALLEL_DAS_DML`](#disable_parallel_das_dml)
  - [`DISABLE_PARALLEL_DML`](#disable_parallel_dml)
  - [`DISABLE_TRIGGER`](#disable_trigger)
  - [`DYNAMIC_SAMPLING`](#dynamic_sampling)
  - [`ENABLE_PARALLEL_DAS_DML`](#enable_parallel_das_dml)
  - [`ENABLE_PARALLEL_DML`](#enable_parallel_dml)
  - [`LOAD_BATCH_SIZE`](#load_batch_size)
  - [`LOG_LEVEL`](#log_level)
  - [`MAX_CONCURRENT`](#max_concurrent)
  - [`MONITOR`](#monitor)
  - [`MV_REWRITE`](#mv_rewrite)
  - [`NO_DIRECT`](#no_direct)
  - [`NO_MV_REWRITE`](#no_mv_rewrite)
  - [`NO_PARALLEL`](#no_parallel)
  - [`OPT_PARAM`](#opt_param)
  - [`PARALLEL`](#parallel)
  - [`QUERY_TIMEOUT`](#query_timeout)
  - [`READ_CONSISTENCY`](#read_consistency)
  - [`RESOURCE_GROUP`](#resource_group)
  - [`STAT`](#stat)
  - [`TRACING`](#tracing)
  - [`TRANS_PARAM`](#trans_param)
  - [`USE_PLAN_CACHE`](#use_plan_cache)
  - [`USE_PX`](#use_px)
- **Global > Transformation**
  - [`NO_COST_BASED_QUERY_TRANSFORMATION`](#no_cost_based_query_transformation)
  - [`NO_QUERY_TRANSFORMATION`](#no_query_transformation)
- **Outline**
  - [`OPTIMIZER_FEATURES_ENABLE`](#optimizer_features_enable)
  - [`QB_NAME`](#qb_name)
- **Query block > Access path**
  - [`FULL`](#full)
  - [`INDEX`](#index)
  - [`INDEX_MERGE`](#index_merge)
  - [`INDEX_SS`](#index_ss)
  - [`NO_INDEX`](#no_index)
  - [`NO_INDEX_MERGE`](#no_index_merge)
  - [`NO_USE_COLUMN_TABLE`](#no_use_column_table)
  - [`NO_USE_DAS`](#no_use_das)
  - [`USE_COLUMN_TABLE`](#use_column_table)
  - [`USE_DAS`](#use_das)
- **Query block > Cost-based transformation**
  - [`COALESCE_SQ`](#coalesce_sq)
  - [`MERGE`](#merge)
  - [`NO_COALESCE_SQ`](#no_coalesce_sq)
  - [`NO_EXPAND`](#no_expand)
  - [`NO_MERGE`](#no_merge)
  - [`NO_PLACE_GROUP_BY`](#no_place_group_by)
  - [`NO_SEMI_TO_INNER`](#no_semi_to_inner)
  - [`NO_WIN_MAGIC`](#no_win_magic)
  - [`PLACE_GROUP_BY`](#place_group_by)
  - [`SEMI_TO_INNER`](#semi_to_inner)
  - [`USE_CONCAT`](#use_concat)
  - [`WIN_MAGIC`](#win_magic)
- **Query block > DISTINCT**
  - [`DISTINCT_PUSHDOWN`](#distinct_pushdown)
  - [`NO_DISTINCT_PUSHDOWN`](#no_distinct_pushdown)
  - [`NO_USE_HASH_DISTINCT`](#no_use_hash_distinct)
  - [`USE_HASH_DISTINCT`](#use_hash_distinct)
- **Query block > Distributed DML**
  - [`NO_USE_DISTRIBUTED_DML`](#no_use_distributed_dml)
  - [`USE_DISTRIBUTED_DML`](#use_distributed_dml)
- **Query block > GROUP BY**
  - [`DISABLE_OP_RICH_FORMAT`](#disable_op_rich_format)
  - [`GBY_PUSHDOWN`](#gby_pushdown)
  - [`NO_GBY_PUSHDOWN`](#no_gby_pushdown)
  - [`NO_USE_HASH_AGGREGATION`](#no_use_hash_aggregation)
  - [`USE_HASH_AGGREGATION`](#use_hash_aggregation)
- **Query block > Heuristic transformation**
  - [`AGGR_FIRST_UNNEST`](#aggr_first_unnest)
  - [`COUNT_TO_EXISTS`](#count_to_exists)
  - [`ELIMINATE_JOIN`](#eliminate_join)
  - [`FAST_MINMAX`](#fast_minmax)
  - [`INLINE`](#inline)
  - [`JOIN_FIRST_UNNEST`](#join_first_unnest)
  - [`LEFT_TO_ANTI`](#left_to_anti)
  - [`MATERIALIZE`](#materialize)
  - [`NO_AGGR_FIRST_UNNEST`](#no_aggr_first_unnest)
  - [`NO_COUNT_TO_EXISTS`](#no_count_to_exists)
  - [`NO_ELIMINATE_JOIN`](#no_eliminate_join)
  - [`NO_FAST_MINMAX`](#no_fast_minmax)
  - [`NO_JOIN_FIRST_UNNEST`](#no_join_first_unnest)
  - [`NO_LEFT_TO_ANTI`](#no_left_to_anti)
  - [`NO_OUTER_TO_INNER`](#no_outer_to_inner)
  - [`NO_PRED_DEDUCE`](#no_pred_deduce)
  - [`NO_PROJECT_PRUNE`](#no_project_prune)
  - [`NO_PULLUP_EXPR`](#no_pullup_expr)
  - [`NO_PUSH_LIMIT`](#no_push_limit)
  - [`NO_REPLACE_CONST`](#no_replace_const)
  - [`NO_SIMPLIFY_DISTINCT`](#no_simplify_distinct)
  - [`NO_SIMPLIFY_EXPR`](#no_simplify_expr)
  - [`NO_SIMPLIFY_GROUP_BY`](#no_simplify_group_by)
  - [`NO_SIMPLIFY_LIMIT`](#no_simplify_limit)
  - [`NO_SIMPLIFY_ORDER_BY`](#no_simplify_order_by)
  - [`NO_SIMPLIFY_SET`](#no_simplify_set)
  - [`NO_SIMPLIFY_SUBQUERY`](#no_simplify_subquery)
  - [`NO_SIMPLIFY_WINFUNC`](#no_simplify_winfunc)
  - [`NO_UNNEST`](#no_unnest)
  - [`OUTER_TO_INNER`](#outer_to_inner)
  - [`PRED_DEDUCE`](#pred_deduce)
  - [`PROJECT_PRUNE`](#project_prune)
  - [`PULLUP_EXPR`](#pullup_expr)
  - [`PUSH_LIMIT`](#push_limit)
  - [`REPLACE_CONST`](#replace_const)
  - [`SIMPLIFY_DISTINCT`](#simplify_distinct)
  - [`SIMPLIFY_EXPR`](#simplify_expr)
  - [`SIMPLIFY_GROUP_BY`](#simplify_group_by)
  - [`SIMPLIFY_LIMIT`](#simplify_limit)
  - [`SIMPLIFY_ORDER_BY`](#simplify_order_by)
  - [`SIMPLIFY_SET`](#simplify_set)
  - [`SIMPLIFY_SUBQUERY`](#simplify_subquery)
  - [`SIMPLIFY_WINFUNC`](#simplify_winfunc)
  - [`UNNEST`](#unnest)
- **Query block > Join operations**
  - [`NO_PX_JOIN_FILTER`](#no_px_join_filter)
  - [`NO_PX_PART_JOIN_FILTER`](#no_px_part_join_filter)
  - [`NO_USE_HASH`](#no_use_hash)
  - [`NO_USE_MERGE`](#no_use_merge)
  - [`NO_USE_NL`](#no_use_nl)
  - [`NO_USE_NL_MATERIALIZATION`](#no_use_nl_materialization)
  - [`PQ_DISTRIBUTE`](#pq_distribute)
  - [`PX_JOIN_FILTER`](#px_join_filter)
  - [`PX_PART_JOIN_FILTER`](#px_part_join_filter)
  - [`USE_HASH`](#use_hash)
  - [`USE_MERGE`](#use_merge)
  - [`USE_NL`](#use_nl)
  - [`USE_NL_MATERIALIZATION`](#use_nl_materialization)
- **Query block > Join order**
  - [`JOIN_ORDER`](#join_order)
  - [`LEADING`](#leading)
  - [`ORDERED`](#ordered)
- **Query block > Other transformation**
  - [`DECORRELATE`](#decorrelate)
  - [`NO_DECORRELATE`](#no_decorrelate)
- **Query block > Set operations**
  - [`NO_USE_HASH_SET`](#no_use_hash_set)
  - [`PQ_SET`](#pq_set)
  - [`USE_HASH_SET`](#use_hash_set)
- **Query block > Statement transformation**
  - [`NO_REWRITE`](#no_rewrite)
- **Query block > Subquery**
  - [`NO_PUSH_SUBQ`](#no_push_subq)
  - [`PQ_SUBQUERY`](#pq_subquery)
  - [`PUSH_SUBQ`](#push_subq)
- **Shared optimizer guide**
  - [`UNION_MERGE`](#union_merge)
- **Tracing**
  - [`TRACE_LOG`](#trace_log)

## Complete inventory

| Hint | Category | Mode documentation | Example documented |
|---|---|---|---|
| [`GATHER_OPTIMIZER_STATISTICS`](#gather_optimizer_statistics) | Global > Optimizer statistics | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_GATHER_OPTIMIZER_STATISTICS`](#no_gather_optimizer_statistics) | Global > Optimizer statistics | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`APPEND`](#append) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`CURSOR_SHARING_EXACT`](#cursor_sharing_exact) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`DIRECT`](#direct) | Global > Other | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`DISABLE_PARALLEL_DAS_DML`](#disable_parallel_das_dml) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`DISABLE_PARALLEL_DML`](#disable_parallel_dml) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`DISABLE_TRIGGER`](#disable_trigger) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`DYNAMIC_SAMPLING`](#dynamic_sampling) | Global > Other; Query block > Access path | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`ENABLE_PARALLEL_DAS_DML`](#enable_parallel_das_dml) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`ENABLE_PARALLEL_DML`](#enable_parallel_dml) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`LOAD_BATCH_SIZE`](#load_batch_size) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`LOG_LEVEL`](#log_level) | Global > Other | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`MAX_CONCURRENT`](#max_concurrent) | Global > Other | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`MONITOR`](#monitor) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`MV_REWRITE`](#mv_rewrite) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | No |
| [`NO_DIRECT`](#no_direct) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_MV_REWRITE`](#no_mv_rewrite) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_PARALLEL`](#no_parallel) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`OPT_PARAM`](#opt_param) | Global > Other | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`PARALLEL`](#parallel) | Global > Other; Query block > Access path; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`QUERY_TIMEOUT`](#query_timeout) | Global > Other | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`READ_CONSISTENCY`](#read_consistency) | Global > Other | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`RESOURCE_GROUP`](#resource_group) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`STAT`](#stat) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`TRACING`](#tracing) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`TRANS_PARAM`](#trans_param) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_PLAN_CACHE`](#use_plan_cache) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_PX`](#use_px) | Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_COST_BASED_QUERY_TRANSFORMATION`](#no_cost_based_query_transformation) | Global > Transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_QUERY_TRANSFORMATION`](#no_query_transformation) | Global > Transformation; Global > Other | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`OPTIMIZER_FEATURES_ENABLE`](#optimizer_features_enable) | Outline | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`QB_NAME`](#qb_name) | Outline | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`FULL`](#full) | Query block > Access path; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`INDEX`](#index) | Query block > Access path; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`INDEX_MERGE`](#index_merge) | Query block > Access path | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`INDEX_SS`](#index_ss) | Query block > Access path | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_INDEX`](#no_index) | Query block > Access path | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_INDEX_MERGE`](#no_index_merge) | Query block > Access path | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_COLUMN_TABLE`](#no_use_column_table) | Query block > Access path | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_DAS`](#no_use_das) | Query block > Access path | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_COLUMN_TABLE`](#use_column_table) | Query block > Access path | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_DAS`](#use_das) | Query block > Access path | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`COALESCE_SQ`](#coalesce_sq) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`MERGE`](#merge) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_COALESCE_SQ`](#no_coalesce_sq) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_EXPAND`](#no_expand) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_MERGE`](#no_merge) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_PLACE_GROUP_BY`](#no_place_group_by) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SEMI_TO_INNER`](#no_semi_to_inner) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_WIN_MAGIC`](#no_win_magic) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PLACE_GROUP_BY`](#place_group_by) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SEMI_TO_INNER`](#semi_to_inner) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_CONCAT`](#use_concat) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`WIN_MAGIC`](#win_magic) | Query block > Cost-based transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`DISTINCT_PUSHDOWN`](#distinct_pushdown) | Query block > DISTINCT | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_DISTINCT_PUSHDOWN`](#no_distinct_pushdown) | Query block > DISTINCT | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_HASH_DISTINCT`](#no_use_hash_distinct) | Query block > DISTINCT | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_HASH_DISTINCT`](#use_hash_distinct) | Query block > DISTINCT | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_DISTRIBUTED_DML`](#no_use_distributed_dml) | Query block > Distributed DML | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_DISTRIBUTED_DML`](#use_distributed_dml) | Query block > Distributed DML | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`DISABLE_OP_RICH_FORMAT`](#disable_op_rich_format) | Query block > GROUP BY | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`GBY_PUSHDOWN`](#gby_pushdown) | Query block > GROUP BY | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_GBY_PUSHDOWN`](#no_gby_pushdown) | Query block > GROUP BY | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_HASH_AGGREGATION`](#no_use_hash_aggregation) | Query block > GROUP BY | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_HASH_AGGREGATION`](#use_hash_aggregation) | Query block > GROUP BY | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`AGGR_FIRST_UNNEST`](#aggr_first_unnest) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`COUNT_TO_EXISTS`](#count_to_exists) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`ELIMINATE_JOIN`](#eliminate_join) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`FAST_MINMAX`](#fast_minmax) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`INLINE`](#inline) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`JOIN_FIRST_UNNEST`](#join_first_unnest) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`LEFT_TO_ANTI`](#left_to_anti) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`MATERIALIZE`](#materialize) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_AGGR_FIRST_UNNEST`](#no_aggr_first_unnest) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_COUNT_TO_EXISTS`](#no_count_to_exists) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_ELIMINATE_JOIN`](#no_eliminate_join) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_FAST_MINMAX`](#no_fast_minmax) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_JOIN_FIRST_UNNEST`](#no_join_first_unnest) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_LEFT_TO_ANTI`](#no_left_to_anti) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_OUTER_TO_INNER`](#no_outer_to_inner) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_PRED_DEDUCE`](#no_pred_deduce) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_PROJECT_PRUNE`](#no_project_prune) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_PULLUP_EXPR`](#no_pullup_expr) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_PUSH_LIMIT`](#no_push_limit) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_REPLACE_CONST`](#no_replace_const) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SIMPLIFY_DISTINCT`](#no_simplify_distinct) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SIMPLIFY_EXPR`](#no_simplify_expr) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SIMPLIFY_GROUP_BY`](#no_simplify_group_by) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SIMPLIFY_LIMIT`](#no_simplify_limit) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SIMPLIFY_ORDER_BY`](#no_simplify_order_by) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SIMPLIFY_SET`](#no_simplify_set) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SIMPLIFY_SUBQUERY`](#no_simplify_subquery) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_SIMPLIFY_WINFUNC`](#no_simplify_winfunc) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_UNNEST`](#no_unnest) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`OUTER_TO_INNER`](#outer_to_inner) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PRED_DEDUCE`](#pred_deduce) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PROJECT_PRUNE`](#project_prune) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PULLUP_EXPR`](#pullup_expr) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PUSH_LIMIT`](#push_limit) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`REPLACE_CONST`](#replace_const) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SIMPLIFY_DISTINCT`](#simplify_distinct) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SIMPLIFY_EXPR`](#simplify_expr) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SIMPLIFY_GROUP_BY`](#simplify_group_by) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SIMPLIFY_LIMIT`](#simplify_limit) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SIMPLIFY_ORDER_BY`](#simplify_order_by) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SIMPLIFY_SET`](#simplify_set) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SIMPLIFY_SUBQUERY`](#simplify_subquery) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`SIMPLIFY_WINFUNC`](#simplify_winfunc) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`UNNEST`](#unnest) | Query block > Heuristic transformation | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`NO_PX_JOIN_FILTER`](#no_px_join_filter) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | No |
| [`NO_PX_PART_JOIN_FILTER`](#no_px_part_join_filter) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_HASH`](#no_use_hash) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_MERGE`](#no_use_merge) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_NL`](#no_use_nl) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_NL_MATERIALIZATION`](#no_use_nl_materialization) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PQ_DISTRIBUTE`](#pq_distribute) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PX_JOIN_FILTER`](#px_join_filter) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | No |
| [`PX_PART_JOIN_FILTER`](#px_part_join_filter) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | No |
| [`USE_HASH`](#use_hash) | Query block > Join operations; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`USE_MERGE`](#use_merge) | Query block > Join operations; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`USE_NL`](#use_nl) | Query block > Join operations; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`USE_NL_MATERIALIZATION`](#use_nl_materialization) | Query block > Join operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`JOIN_ORDER`](#join_order) | Query block > Join order | MySQL mode (official JSON_TABLE example only) | Yes |
| [`LEADING`](#leading) | Query block > Join order; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`ORDERED`](#ordered) | Query block > Join order; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`DECORRELATE`](#decorrelate) | Query block > Other transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_DECORRELATE`](#no_decorrelate) | Query block > Other transformation | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_USE_HASH_SET`](#no_use_hash_set) | Query block > Set operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PQ_SET`](#pq_set) | Query block > Set operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`USE_HASH_SET`](#use_hash_set) | Query block > Set operations | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`NO_REWRITE`](#no_rewrite) | Query block > Statement transformation | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`NO_PUSH_SUBQ`](#no_push_subq) | Query block > Subquery; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`PQ_SUBQUERY`](#pq_subquery) | Query block > Subquery | Oracle mode (dedicated chapter); MySQL applicability not separately enumerated | Yes |
| [`PUSH_SUBQ`](#push_subq) | Query block > Subquery; Shared optimizer guide | Oracle mode (dedicated chapter); MySQL-mode evidence also present | Yes |
| [`UNION_MERGE`](#union_merge) | Shared optimizer guide | Shared optimizer guide; MySQL SELECT documentation references this guide | Yes |
| [`TRACE_LOG`](#trace_log) | Tracing | Mode not specified on the source page | Yes |

## Detailed hint reference

## Global > Optimizer statistics

### GATHER_OPTIMIZER_STATISTICS

**Purpose:** The `GATHER_OPTIMIZER_STATISTICS` Hint specifies to collect statistics online during the execution of `INSERT INTO...SELECT`. For more information, see Online statistics collection. Its opposite is `NO_GATHER_OPTIMIZER_STATISTICS`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Optimizer statistics.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/100.optimizer-stats-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/100.optimizer-stats-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Optimizer statistics

The `GATHER_OPTIMIZER_STATISTICS` Hint specifies to collect statistics online during the execution of `INSERT INTO...SELECT`. For more information, see [Online statistics collection](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/400.optimizer-statistics/200.statistics-collection-methods/500.online-statistics-collection.md). Its opposite is `NO_GATHER_OPTIMIZER_STATISTICS`.

**Syntax**


```sql
/*+ GATHER_OPTIMIZER_STATISTICS */
```


**Example**


```sql
-- Indicates to the database optimizer to collect optimizer statistics after inserting data from table t2 into table t1.
INSERT /*+ GATHER_OPTIMIZER_STATISTICS */ INTO t1 SELECT * FROM t2;
```

### NO_GATHER_OPTIMIZER_STATISTICS

**Purpose:** The `NO_GATHER_OPTIMIZER_STATISTICS` Hint specifies to disable online statistics collection. It is the opposite of the `GATHER_OPTIMIZER_STATISTICS` Hint. For more information, see Online statistics collection. Its opposite is `GATHER_OPTIMIZER_STATISTICS`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Optimizer statistics.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/100.optimizer-stats-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/100.optimizer-stats-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Optimizer statistics

The `NO_GATHER_OPTIMIZER_STATISTICS` Hint specifies to disable online statistics collection. It is the opposite of the `GATHER_OPTIMIZER_STATISTICS` Hint. For more information, see [Online statistics collection](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/400.optimizer-statistics/200.statistics-collection-methods/500.online-statistics-collection.md). Its opposite is `GATHER_OPTIMIZER_STATISTICS`.

**Syntax**


```sql
/*+ NO_GATHER_OPTIMIZER_STATISTICS */
```


**Example**


```sql
-- Indicates to the database optimizer not to collect optimizer statistics after inserting data from table t2 into table t1.
INSERT /*+ NO_GATHER_OPTIMIZER_STATISTICS */ INTO t1 SELECT * FROM t2;
```

## Global > Other

### APPEND

**Purpose:** `APPEND` Hint specifies to enable direct load in `INSERT INTO SELECT` statements. For more information, see Use the `INSERT INTO SELECT` statement to directly load data.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

`APPEND` Hint specifies to enable direct load in `INSERT INTO SELECT` statements. For more information, see [Use the `INSERT INTO SELECT` statement to directly load data](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/620.obap/300.obap-data-collection/300.obap-import-data/20.bypass-import/100.overview-of-bypass-import.md).

**Syntax**


```sql
/*+ APPEND */
```


**Examples**


```sql
INSERT /*+ append enable_parallel_dml parallel(16) */ INTO t2
SELECT * FROM t1;
```

### CURSOR_SHARING_EXACT

**Purpose:** `CURSOR_SHARING_EXACT` Hint specifies to disable parameterization at the query level. OceanBase Database supports replacing literals in SQL statements with bind variables. This feature is controlled by the `CURSOR_SHARING` variable. When `cursor_sharing='exact'`, parameterization is not required. For more information, see cursor_sharing.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

`CURSOR_SHARING_EXACT` Hint specifies to disable parameterization at the query level.

OceanBase Database supports replacing literals in SQL statements with bind variables. This feature is controlled by the `CURSOR_SHARING` variable. When `cursor_sharing='exact'`, parameterization is not required. For more information, see [cursor_sharing](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/800.configuration-items-and-system-variables/200.system-variable/300.global-system-variable/1900.cursor_sharing-global.md).

**Syntax**


```sql
/*+ CURSOR_SHARING_EXACT */
```


**Examples**


The following example shows how to disable parameterization using the `CURSOR_SHARING_EXACT` Hint. After executing the query with two sets of parameters four times, two query plans are generated in the plan cache for different parameters.

```sql
alter system flush plan cache global;
SELECT /*+ CURSOR_SHARING_EXACT */ * FROM t1 WHERE c1=5;
SELECT /*+ CURSOR_SHARING_EXACT */ * FROM t1 WHERE c1=5;
SELECT /*+ CURSOR_SHARING_EXACT */ * FROM t1 WHERE c1=6;
SELECT /*+ CURSOR_SHARING_EXACT */ * FROM t1 WHERE c1=6;

SELECT sql_id, plan_id, statement FROM oceanbase.gv$ob_plan_cache_plan_stat where query_sql like "SELECT /*+ CURSOR_SHARING_EXACT */ * FROM t1 WHERE c1=%";
```

### DIRECT

**Purpose:** `DIRECT` Hint can be specified in `LOAD DATA` and `INSERT` statements to enable direct load, thereby improving the efficiency and performance of data import.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

`DIRECT` Hint can be specified in `LOAD DATA` and `INSERT` statements to enable direct load, thereby improving the efficiency and performance of data import.

**Syntax**


The syntax of `DIRECT` Hint is as follows:

```sql
/*+ DIRECT (/*+ direct(need_sort, max_errors_allowed, load_mode) */)*/
```


**Parameters**


- `need_sort`: specifies whether to sort the imported data. `true` indicates that sorting is required. `false` indicates that sorting is not required.

- `max_errors_allowed`: specifies the maximum number of allowed error rows. If this number is exceeded, the import process will fail.

- `load_mode`: specifies the import mode. The options are as follows:

  + `full`: the default value, indicating a full import.
  + `inc`: indicating an incremental import, which supports `INSERT` and `IGNORE` semantics.
  + `inc_replace`: indicating an incremental import without checking for duplicate primary keys, equivalent to `REPLACE` semantics.

**Examples**


**`DIRECT` Hint in `LOAD DATA` statements**


**Enable incremental direct load**

```sql
LOAD DATA /*+ DIRECT(true, 0, inc) */
INFILE 'datafile.txt'
INTO TABLE mytable
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```


In this example, `DIRECT(true, 0, inc)` enables incremental direct load, performs sorting, and allows up to 0 error rows.

**Enable full direct load**

```sql
LOAD DATA
/*+ PARALLEL(4) DIRECT(true, 0, full) */
REMOTE_OSS INFILE 'oss://example.com/datafile.csv'
INTO TABLE my_table
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```


In this example, `PARALLEL(4)` specifies a parallelism of 4, and `DIRECT(true, 0, full)` enables full direct load, performs sorting, and allows up to 0 error rows.

For more information, see [Direct load](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/620.obap/300.obap-data-collection/300.obap-import-data/20.bypass-import/100.overview-of-bypass-import.md).

**`DIRECT` Hint in `INSERT INTO SELECT` statements**


In `INSERT INTO SELECT` statements, to enable direct load, you must use `enable_parallel_dml` in the following format: `/*+ direct(bool, int, load_mode) enable_parallel_dml PARALLEL(N) */`.

**Enable incremental direct load**

```sql
-- Enable incremental direct load and parallel DML to incrementally import data from old_table to new_table
INSERT /*+ direct(true, 0, 'inc') enable_parallel_dml PARALLEL(4) */ INTO new_table (id, name, value)
SELECT id, name, value
FROM old_table;
```


In this example, `direct(true, 0, 'inc')` enables incremental direct load, performs sorting, and allows up to 0 error rows. `enable_parallel_dml` enables parallel DML. `PARALLEL(4)` sets the parallelism to 4.

**Enable full direct load**

```sql
-- Enable full direct load and parallel DML to import data from old_table to new_table
INSERT /*+ direct(true, 0, 'full') enable_parallel_dml PARALLEL(4) */ INTO new_table (id, name, value)
SELECT id, name, value
FROM old_table;
```


In this example, `direct(true, 0, 'full')` enables full direct load, performs sorting, and allows up to 0 error rows. `enable_parallel_dml` enables parallel DML. `PARALLEL(4)` sets the parallelism to 4.

For more information, see [Use the `INSERT INTO SELECT` statement to directly load data](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/620.obap/300.obap-data-collection/300.obap-import-data/20.bypass-import/100.overview-of-bypass-import.md).

**MySQL-mode evidence:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/5900.load-data-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/5900.load-data-of-mysql-mode.md)

### DISABLE_PARALLEL_DAS_DML

**Purpose:** The `DISABLE_PARALLEL_DAS_DML` hint is used to force the disablement of Distributed Data Access Service (DAS) concurrent writes for the current DML statement. Its reverse hint is `ENABLE_PARALLEL_DAS_DML`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `DISABLE_PARALLEL_DAS_DML` hint is used to force the disablement of Distributed Data Access Service (DAS) concurrent writes for the current DML statement. Its reverse hint is `ENABLE_PARALLEL_DAS_DML`.

**Considerations**


- The `DISABLE_PARALLEL_DAS_DML` hint must be used in conjunction with the `ENABLE_PARALLEL_DML` hint.

- When the `/*+DISABLE_PARALLEL_DAS_DML ENABLE_PARALLEL_DML PARALLEL(n)*/` hint is used, the system will disable DAS concurrent writes, even if other concurrent write optimization options like PDML are enabled.

**Syntax**


```sql
/*+ DISABLE_PARALLEL_DAS_DML */
```


**Examples**


```sql
insert /*+ DISABLE_PARALLEL_DAS_DML ENABLE_PARALLEL_DML PARALLEL(10)*/
into t1 select * from t2;
```

### DISABLE_PARALLEL_DML

**Purpose:** The `DISABLE_PARALLEL_DML` hint specifies to disable parallel DML for the current query. Its reverse hint is `ENABLE_PARALLEL_DML`, which is used to enable parallel DML. For more information, see Parallel DML.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `DISABLE_PARALLEL_DML` hint specifies to disable parallel DML for the current query. Its reverse hint is `ENABLE_PARALLEL_DML`, which is used to enable parallel DML.

For more information, see [Parallel DML](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/300.distributed-execution-plan/1000.parallel-dml.md).

**Syntax**


```sql
/*+ DISABLE_PARALLEL_DML */
```


**Examples**


```sql
insert /*+ disable_parallel_dml parallel(8) */ into t2 select * from t1;
```

### DISABLE_TRIGGER

**Purpose:** The `DISABLE_TRIGGER` hint disables the specified trigger in DML operations.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `DISABLE_TRIGGER` hint disables the specified trigger in DML operations.

**Syntax**


```sql
/*+ disable_trigger[(trigger_name)] */
```


**Parameters**


`trigger_name`: an optional parameter that specifies the name of the trigger to be temporarily disabled. You can specify one or more trigger names, separated by commas. If you omit this parameter, all triggers involved in the query are disabled by default.

**Examples**


The following example disables the trigger named `test_trigger1`.

```sql
INSERT /*+ disable_trigger[(test_trigger1)] */ INTO test VALUES(2);
```

### DYNAMIC_SAMPLING

**Purpose:** The `DYNAMIC_SAMPLING` hint specifies whether to enable dynamic sampling for a query.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other; Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `DYNAMIC_SAMPLING` hint specifies whether to enable dynamic sampling for a query.

**Syntax**


```sql
/*+ DYNAMIC_SAMPLING ( 0 | 1 ) */
```


**Parameter description**


The parameters of the `DYNAMIC_SAMPLING` hint are described as follows:

- When the parameter is set to 0, dynamic sampling is disabled.
- When the parameter is set to 1, dynamic sampling is enabled.

**Examples**


The following example shows how to use the `DYNAMIC_SAMPLING` hint to enable dynamic sampling.

```sql
SELECT /*+ dynamic_sampling(1) */ *
FROM t1 WHERE c1 LIKE "%abc%" AND c2 LIKE "%abc%";
```

#### Documentation section 2: Query block > Access path

The `DYNAMIC_SAMPLING` Hint specifies whether to use dynamic sampling. Dynamic sampling improves query execution plans, especially when statistics are insufficient or inaccurate.

**Syntax**


```sql
/*+DYNAMIC_SAMPLING( [[ qb_name_option ] table_name ] INTNUM1 [, INTNUM2 ] ) */
```


**Parameters**


- `qb_name_option`: the name of the query block. This parameter is optional.
- `table_name`: the name of the table to use dynamic sampling. This parameter is optional. If this parameter is not specified, dynamic sampling is used for the entire query.
- `INTNUM1`: specifies the sampling level. Currently, only 0 and 1 are supported. 1 indicates that dynamic sampling is enabled. 0 indicates that dynamic sampling is disabled.
- `INTNUM2`: specifies the number of microblocks to sample. We recommend that you set this parameter to a value greater than 32.

**Examples**


```sql
-- Enable dynamic sampling for table t1 when you execute the query.
SELECT /*+DYNAMIC_SAMPLING(t1 1)*/ c4 FROM t1 WHERE c1 > 1 AND c2 > 1 AND c3 > 1 GROUP BY c4;
```

### ENABLE_PARALLEL_DAS_DML

**Purpose:** The `ENABLE_PARALLEL_DAS_DML` hint is used to force the use of Distributed Data Access Service (DAS) concurrent writes for the current DML statement. Its reverse hint is `DISABLE_PARALLEL_DAS_DML`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `ENABLE_PARALLEL_DAS_DML` hint is used to force the use of Distributed Data Access Service (DAS) concurrent writes for the current DML statement. Its reverse hint is `DISABLE_PARALLEL_DAS_DML`.

**Considerations**


- The `ENABLE_PARALLEL_DAS_DML` hint must be used in conjunction with the `ENABLE_PARALLEL_DML` hint.

- When the `/*+ENABLE_PARALLEL_DAS_DML ENABLE_PARALLEL_DML PARALLEL(n)*/` hint is used, the system will treat DAS concurrent writes as the forced option and execute the operation based on the parallelism specified by `PARALLEL(n)`.

- If the system parameter `_enable_parallel_das_dml` is set to `true` using the `ALTER SYSTEM SET` statement (default is `false`), the `/*+ENABLE_PARALLEL_DAS_DML ENABLE_PARALLEL_DML PARALLEL(n)*/` hint will be ineffective. In this case, the system will not perform DAS parallel writes.

**Syntax**


```sql
/*+ ENABLE_PARALLEL_DAS_DML */
```


**Examples**


```sql
insert /*+ ENABLE_PARALLEL_DAS_DML ENABLE_PARALLEL_DML PARALLEL(10)*/
into t1 select * from t2;
```

### ENABLE_PARALLEL_DML

**Purpose:** The `ENABLE_PARALLEL_DML` hint specifies to enable parallel DML for the current query. Its reverse hint is `DISABLE_PARALLEL_DML`, which is used to disable parallel DML. For more information, see Parallel DML.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `ENABLE_PARALLEL_DML` hint specifies to enable parallel DML for the current query. Its reverse hint is `DISABLE_PARALLEL_DML`, which is used to disable parallel DML.

For more information, see [Parallel DML](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/300.distributed-execution-plan/1000.parallel-dml.md).

**Considerations**


- When using `/*+ENABLE_PARALLEL_DML PARALLEL(n)*/`, the system prioritizes distributed parallel DML (PDML). If the current environment does not support PDML, it will fall back to DAS concurrent writes as a performance optimization.

- When a forced parallelism level is set at the session level, its execution behavior will remain consistent with the above behavior.

- Even if the current environment does not support parallel DML (PDML), if the system parameter `_enable_parallel_das_dml` is set to `true` using the `ALTER SYSTEM SET` command (its default value is `false`), the system will not enable DAS (Distributed Active Storage) parallel writes, even if the `/*+ENABLE_PARALLEL_DML PARALLEL(n)*/` hint is used.

- When `_enable_parallel_das_dml` is set to `true` using the `ALTER SYSTEM SET` command (default is `false`), and a forced parallelism level is already set at the session level, using the `/*+ENABLE_PARALLEL_DML PARALLEL(n)*/` hint will not enable DAS parallel writes.

**Syntax**


```sql
/*+ ENABLE_PARALLEL_DML */
```


**Examples**


```sql
insert /*+ enable_parallel_dml parallel(8) */ into t2 select * from t1;
```

### LOAD_BATCH_SIZE

**Purpose:** The `LOAD_BATCH_SIZE` hint is used in `LOAD DATA` to specify the size of the batch of records to be inserted each time. In the `LOAD_BATCH_SIZE` hint, `batch_size` specifies the size of the batch of records to be inserted each time. For more information about `LOAD DATA`, see LOAD DATA.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `LOAD_BATCH_SIZE` hint is used in `LOAD DATA` to specify the size of the batch of records to be inserted each time.

In the `LOAD_BATCH_SIZE` hint, `batch_size` specifies the size of the batch of records to be inserted each time. For more information about `LOAD DATA`, see [LOAD DATA](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/900.sql-statement-of-oracle-mode/300.dcl-of-oracle-mode/1900.load-data-of-oracle-mode.md).

**Syntax**


```sql
/*+ LOAD_BATCH_SIZE ( batch_size ) */
```


**Example**


```sql
-- Use 4 parallel processes to import data, append new data to the end of the table, and set each batch to process 1000 records using the `LOAD_BATCH_SIZE` hint.
LOAD DATA /*+ PARALLEL(4) APPEND LOAD_BATCH_SIZE(1000) */
INFILE '/home/admin/test.csv' INTO TABLE t1;
```

### LOG_LEVEL

**Purpose:** The `LOG_LEVEL` hint is used to specify the log level for the current query during execution. In the `LOG_LEVEL` hint, `log_level` specifies the log level. Common log levels include `ERROR`, `WARN`, `INFO`, `TRACE`, and `DEBUG`. For more information about log levels, see Log levels.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `LOG_LEVEL` hint is used to specify the log level for the current query during execution.

In the `LOG_LEVEL` hint, `log_level` specifies the log level. Common log levels include `ERROR`, `WARN`, `INFO`, `TRACE`, and `DEBUG`.

For more information about log levels, see [Log levels](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/600.manage/800.logging/200.log-level.md).

**Syntax**


```sql
/*+ LOG_LEVEL ( [']log_level['] ) */
```


**Example**


```sql
-- Use the LOG_LEVEL hint to specify the `TRACE` log level.
SELECT /*+ LOG_LEVEL(TRACE) */ *
FROM employees e
WHERE e.department_id = 1001;
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

### MAX_CONCURRENT

**Purpose:** The `MAX_CONCURRENT` hint is used to specify the maximum number of concurrent executions for a query. In the `MAX_CONCURRENT` hint, `intnum` specifies the maximum number of concurrent executions allowed for the query. If the number of concurrent executions exceeds the maximum allowed, an error is returned when the query is executed. If `intnum` is set to 0, an error is always returned when the query is executed. Note that currently, the `MAX_CONCURRENT` hint cannot be directly used in a query. Instead, you can create an outline that contains only the `MAX_CONCURRENT` hint to limit the concurrency of specific SQL statements.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `MAX_CONCURRENT` hint is used to specify the maximum number of concurrent executions for a query.

In the `MAX_CONCURRENT` hint, `intnum` specifies the maximum number of concurrent executions allowed for the query. If the number of concurrent executions exceeds the maximum allowed, an error is returned when the query is executed. If `intnum` is set to 0, an error is always returned when the query is executed.

Note that currently, the `MAX_CONCURRENT` hint cannot be directly used in a query. Instead, you can create an outline that contains only the `MAX_CONCURRENT` hint to limit the concurrency of specific SQL statements.

**Syntax**


```sql
/*+ MAX_CONCURRENT ( intnum ) */
```


**Example**


```sql
-- This query creates an outline named otl1 associated with the identifier 'EC102CB006383D732BC98797601D9B3B' and specifies a maximum of 10 concurrent executions for the corresponding query.
CREATE OUTLINE otl1 ON 'EC102CB006383D732BC98797601D9B3B'
USING HINT /*+ max_concurrent(10) */;
```

**MySQL-mode evidence:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/1300.alter-outline-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/1300.alter-outline-of-mysql-mode.md)

### MONITOR

**Purpose:** The `MONITOR` hint is used to enable the capture of SQL Plan Monitor records for a query. You can use the `MONITOR` hint to record the execution process of a query in the SQL Plan Monitor. For queries that do not use parallel execution, OceanBase Database does not record their execution process in the SQL Plan Monitor. For more information about the SQL Plan Monitor, see the **Real-time SQL Plan Monitor** section in Real-time execution plan display.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `MONITOR` hint is used to enable the capture of SQL Plan Monitor records for a query. You can use the `MONITOR` hint to record the execution process of a query in the SQL Plan Monitor.

For queries that do not use parallel execution, OceanBase Database does not record their execution process in the SQL Plan Monitor.

For more information about the SQL Plan Monitor, see the **Real-time SQL Plan Monitor** section in [Real-time execution plan display](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/200.sql-execution-plan/500.real-time-execution-plan-display.md).

**Syntax**


```sql
/*+ MONITOR */
```


**Example**


```sql
-- Use the MONITOR hint to enable SQL Plan Monitor records.
SELECT /*+monitor*/ c1, SUM(distinct c2) FROM t1 GROUP BY c1;
```


**Query rewrite hints**


The query rewrite hints include `MV_REWRITE` and `NO_MV_REWRITE`. These hints have higher priority than the system variable `query_rewrite_enabled`.

### MV_REWRITE

**Purpose:** The syntax of `MV_REWRITE` is as follows:

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

**Official example:** The cited hint documentation does not label an official example; none has been invented.

#### Documentation section 1: Global > Other

The syntax of `MV_REWRITE` is as follows:

```sql
/*+ MV_REWRITE (@ queryblock [mv_name_list]) */

mv_name_list:
    mv_name [, mv_name ...]
```


When you use the `MV_REWRITE` hint alone, you can skip the rule and cost checks for query rewrite and directly use the applicable rewrite. If you specify one or more materialized views after the hint, the rule and cost checks are skipped, and only the specified materialized views are used for query rewrite, ignoring all other materialized views.

When you use the `MV_REWRITE` hint to specify materialized views, you cannot force the use of a materialized view that does not have the `ENABLE QUERY REWRITE` clause. Additionally, you cannot force the use of a non-real-time materialized view when the system variable `query_rewrite_integrity` is set to `enforced`.

### NO_DIRECT

**Purpose:** `NO_DIRECT` Hint disables direct load in `LOAD DATA`, `INSERT INTO SELECT`, and `CREATE TABLE AS SELECT` statements.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

`NO_DIRECT` Hint disables direct load in `LOAD DATA`, `INSERT INTO SELECT`, and `CREATE TABLE AS SELECT` statements.

**Syntax**


The syntax of `NO_DIRECT` Hint is as follows:

```sql
/*+ NO_DIRECT */
```


**Parameters**


`NO_DIRECT`: forces a single SQL statement to not use direct load. If an SQL statement contains this hint, it ignores other direct load hints and executes a regular import.

**Examples**


* **Use NO_DIRECT in a `LOAD DATA` statement**

```sql
LOAD DATA /*+ NO_DIRECT */ [REMOTE_OSS | LOCAL] INFILE 'file_name' INTO TABLE table_name [COMPRESSION]...
```


* **Use NO_DIRECT in an `INSERT INTO SELECT` statement**

```sql
INSERT /*+ NO_DIRECT */ INTO  table_name select_sentence
```


* **Use NO_DIRECT in a `CREATE TABLE AS SELECT` statement**

```sql
CREATE /*+ NO_DIRECT */ TABLE table_name [AS] select_sentence
```

### NO_MV_REWRITE

**Purpose:** The syntax of `NO_MV_REWRITE` is as follows:

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The syntax of `NO_MV_REWRITE` is as follows:

```sql
/*+ NO_MV_REWRITE (@ queryblock) */
```


The `NO_MV_REWRITE` hint disables query rewrite for the specified query block.

**Example of using query rewrite hints**


1. Create the base table `tbl2`.

```sql
CREATE TABLE tbl2 (col1 INT, col2 INT);
```


2. Insert two rows of data into the base table `tbl2`.

```sql
INSERT INTO tbl2 VALUES (1,2),(3,4);
```


   The return result is as follows:


3. Create the materialized view `mv1_tbl2` and enable automatic query rewrite for it.

```sql
CREATE MATERIALIZED VIEW mv1_tbl2 NEVER REFRESH ENABLE QUERY REWRITE AS SELECT * FROM tbl2;
```


4. Create the materialized view `mv2_tbl2` and enable automatic query rewrite for it.

```sql
CREATE MATERIALIZED VIEW mv2_tbl2 NEVER REFRESH ENABLE QUERY REWRITE AS SELECT * FROM tbl2 WHERE tbl2.col1 > 1;
```


5. Set the system variable `query_rewrite_integrity` to `stale_tolerated`.


      **Note**
      The hints `MV_REWRITE` and `NO_MV_REWRITE` have higher priority than the system variable `query_rewrite_enabled`. Therefore, you do not need to set `query_rewrite_enabled`. However, you must set `query_rewrite_integrity` to `stale_tolerated` to use non-real-time materialized views for query rewrite.


```sql
SET query_rewrite_integrity = 'stale_tolerated';
```


6. Use the `MV_REWRITE` hint to attempt query rewrite using materialized views and skip the cost and rule checks. The following two queries will use the materialized view `mv1_tbl2` for query rewrite.

   * `/*+mv_rewrite*/` will attempt to use a materialized view that meets the rewrite conditions for query rewrite. Once a suitable materialized view is found, subsequent materialized views will be ignored, and the cost and rule checks will be skipped.

```sql
EXPLAIN SELECT /*+mv_rewrite*/ count(*), col1 FROM tbl2 WHERE tbl2.col1 > 1 GROUP BY col1;
```


     The return result is as follows:


   * `/*+mv_rewrite(mv1_tbl2)*/` will attempt to use `mv2_tbl2` for query rewrite and skip the cost and rule checks.

```sql
EXPLAIN SELECT /*+mv_rewrite(mv2_tbl2)*/ count(*), col1 FROM tbl2 WHERE tbl2.col1 > 1 GROUP BY col1;
```


     The return result is as follows:


7. Although the query specifies using `mv2_tbl2` for query rewrite, the `WHERE` condition in the query does not meet the requirements, so `mv2_tbl2` cannot be used for query rewrite. Therefore, no query rewrite will be performed.

```sql
EXPLAIN SELECT /*+mv_rewrite(mv2_tbl2)*/ count(*), col1 FROM tbl2 WHERE tbl2.col1 < 1 GROUP BY col1;
```


   The return result is as follows:


8. Use the `/*+ no_mv_rewrite*/` hint to disable query rewrite.

```sql
EXPLAIN SELECT /*+no_mv_rewrite*/ count(*), col1 FROM tbl2 WHERE tbl2.col1 > 1 GROUP BY col1;
```


   The return result is as follows:

### NO_PARALLEL

**Purpose:** The `NO_PARALLEL` hint disables query parallelism (i.e., sets the parallelism to 1). Its opposite hint is `PARALLEL`. The `NO_PARALLEL` hint is equivalent to `/*+ parallel(1)*/`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `NO_PARALLEL` hint disables query parallelism (i.e., sets the parallelism to 1). Its opposite hint is `PARALLEL`.

The `NO_PARALLEL` hint is equivalent to `/*+ parallel(1)*/`.

**Syntax**


```sql
/*+ NO_PARALLEL */
```


**Example**


The following query example uses the `NO_PARALLEL` hint to disable query parallelism.

```sql
SELECT /*+ no_parallel */ c1, sum(distinct c2) FROM t1 GROUP BY c1;
```

### OPT_PARAM

**Purpose:** `OPT_PARAM` Hint specifies some optimizer-related configurations/system variables at the query level.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

`OPT_PARAM` Hint specifies some optimizer-related configurations/system variables at the query level.

**Syntax**


```sql
/*+ OPT_PARAM ( parameter_name [,] parameter_value ) */
```


**Parameters**


* `parameter_name`: the name of the configuration or system variable.

* `parameter_value`: the value of the variable to be specified.

The `OPT_PARAM` Hint is effective for the following parameters:

* `rowsets_enabled`: specifies whether to enable or disable vectorization. The data type is `VARCHAR`, and the value can be `'TRUE'` or `'FALSE'`. The value must be enclosed in single quotation marks (`'`).

* `rowsets_max_rows`: specifies the number of rows to be returned in a batch (`batch_size`). The data type is `INT`, and the value ranges from `[0, 65535]`. The value must not be enclosed in single quotation marks (`'`).

* `enable_newsort`: specifies whether to enable or disable the newsort optimization. The data type is `VARCHAR`, and the value can be `'TRUE'` or `'FALSE'`. The value must be enclosed in single quotation marks (`'`).

* `use_part_sort_mgb`: specifies whether to enable or disable the part sort merge group by. The data type is `VARCHAR`, and the value can be `'TRUE'` or `'FALSE'`. The value must be enclosed in single quotation marks (`'`).

* `enable_in_range_optimization`: specifies whether to enable or disable the in optimization. The data type is `VARCHAR`, and the value can be `'TRUE'` or `'FALSE'`. The value must be enclosed in single quotation marks (`'`).

* `xsolapi_generate_with_clause`: specifies whether to enable or disable the CTE extraction rewrite. The data type is `VARCHAR`, and the value can be `'TRUE'` or `'FALSE'`. The value must be enclosed in single quotation marks (`'`).

* `preserve_order_for_pagination`: specifies whether to add an `order by` clause for pagination queries to preserve order or to prohibit adding an `order by` clause. The data type is `VARCHAR`, and the value can be `'TRUE'` or `'FALSE'`. The value must be enclosed in single quotation marks (`'`).

* `storage_card_estimation`: specifies whether to use the storage layer for row estimation. The data type is `VARCHAR`, and the value can be `'TRUE'` or `'FALSE'`. The value must be enclosed in single quotation marks (`'`).

* `workarea_size_policy`: specifies the strategy for manually or automatically adjusting the SQL work area size. The data type is `VARCHAR`, and the value can be `'MANUAL'` for manual adjustment or `'AUTO'` for automatic adjustment. The value must be enclosed in single quotation marks (`'`).

* `enable_rich_vector_format`: specifies whether to enable or disable vectorization 2.0 (session-level parameter). The data type is `VARCHAR`, and the value can be `'TRUE'` or `'FALSE'`. The value must be enclosed in single quotation marks (`'`).

* `spill_compression_codec`: specifies the compression algorithm to be used for operators that require temporary materialization. The data type is `VARCHAR`, and the value can be `NONE`, `LZ4`, `SNAPPY`, `ZLIB`, or `ZSTD`, representing different compression algorithms. The default value is `NONE`, indicating no compression.

* `inlist_rewrite_threshold`: specifies the threshold for the number of constants that can trigger the rewriting of `inlist` into a `values statement`. The data type is `INT64`, and the value ranges from `[1, 2147483647]`.

* `orc_filter_pushdown_level`: specifies the level at which to push down filter conditions for ORC external tables. The `parameter_value` can be:


      **Note**
      The `OPT_PARAM` Hint in OceanBase Database supports the `orc_filter_pushdown_level` parameter starting from V4.4.0.


  * `0`: disables filter condition pushing down.
  * `1`: pushes down filter conditions to the file level.
  * `2`: pushes down filter conditions to the stripe level.
  * `3`: pushes down filter conditions to the row index level.
  * `4`: pushes down filter conditions to the encoding level.

* `parquet_filter_pushdown_level`: specifies the level at which to push down filter conditions for Parquet external tables. The `parameter_value` can be:


      **Note**
      The `OPT_PARAM` Hint in OceanBase Database supports the `parquet_filter_pushdown_level` parameter starting from V4.4.0.


  * `0`: disables filter condition pushing down.
  * `1`: pushes down filter conditions to the file level.
  * `2`: pushes down filter conditions to the RowGroup level.
  * `3`: pushes down filter conditions to the page level.
  * `4`: pushes down filter conditions to the encoding level.

**Examples**


The following example uses the `OPT_PARAM` Hint to enable IN optimization for the current query by specifying the `enable_in_range_optimization` value.

```shell
SELECT /*+ opt_param('enable_in_range_optimization', 'true') */ *
from t1
where c1 in (1,2,3,4,5,...,1000)
and c2 in (1,2,3,4,5,...,1000);
```

**MySQL-mode evidence:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/100.basic-elements-of-mysql-mode/200.expression-of-mysql-mode/300.type-conversion-of-expression-evaluation-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/100.basic-elements-of-mysql-mode/200.expression-of-mysql-mode/300.type-conversion-of-expression-evaluation-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/500.queries-and-subqueries-of-mysql-mode/400.full-text-query-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/500.queries-and-subqueries-of-mysql-mode/400.full-text-query-of-mysql-mode.md)

### PARALLEL

**Purpose:** When used as a global hint, the `PARALLEL` Hint specifies the parallelism or parallelism strategy for the current query. In addition to being a global hint, the `PARALLEL` Hint can also be used as a query block hint to specify the parallelism at the table level. For more information, see the `Parallel` hint section in Access Path Hints.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Global > Other; Query block > Access path; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Global > Other

When used as a global hint, the `PARALLEL` Hint specifies the parallelism or parallelism strategy for the current query.

In addition to being a global hint, the `PARALLEL` Hint can also be used as a query block hint to specify the parallelism at the table level. For more information, see the `Parallel` hint section in [Access Path Hints](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md).

**Syntax**


```sql
/*+ PARALLEL ( AUTO | MANUAL | parallel_degree) */
```


**Parameters**


- `AUTO` or `MANUAL`: when `AUTO` or `MANUAL` is used as the parameter in the `PARALLEL` Hint, it specifies the parallel execution strategy. For more information, see [Parallel execution modes and priorities](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/300.distributed-execution-plan/500.parallel-execution.md).

- `parallel_degree`: when `parallel_degree` is used as the parameter in the `PARALLEL` Hint, it directly specifies the parallelism.

**Examples**


The following example uses the `PARALLEL` Hint to specify a parallelism of DOP = 8 or to enable auto DOP.

```sql
SELECT /*+parallel(8)*/ c1, SUM(distinct c2) FROM t1 GROUP BY c1;

SELECT /*+parallel(auto)*/ c1, SUM(distinct c2) FROM t1 GROUP BY c1;
```


> Note: Some scenarios do not support parallel execution. Even if you specify the PARALLEL hint to enable parallel execution, the execution plan may still disable parallel execution.

#### Documentation section 2: Query block > Access path

`PARALLEL` Hint is a statement-level hint that instructs the optimizer to specify the number of parallel threads available for parallel operations. This hint overrides the value of the initialization parameter `PARALLEL_DEGREE_POLICY`. The `PARALLEL` hint can be used with `SELECT`, `INSERT`, `UPDATE`, and `DELETE` statements, as well as in table scans. If any parallel limitations are violated, the `PARALLEL` hint is ignored.

**Syntax**


The `PARALLEL` hint at the table level is specified as follows:

```sql
/*+ PARALLEL(table_name n) */
```


When both table-level and global parallelism are specified using hints, the table-level hint has higher priority.

**Examples**


```sql
-- Scan the table with a parallel degree of 8.
SELECT /*+parallel(4) parallel(emp 8) */ last_name
FROM emp;
```

#### Documentation section 3: Shared optimizer guide

The `PARALLEL` hint specifies the degree of parallelism at the statement level. The syntax is as follows:

```sql
/*+ PARALLEL(n) */
```


In the syntax, `n` is an integer that specifies the degree of parallelism.

OceanBase Database also supports the `PARALLEL` hint at the table level. The syntax is as follows:

```sql
/*+ PARALLEL(table_name n) */
```


If both the global and table-level `PARALLEL` hints are specified, the table-level hint will be ignored. Here is an example:

```sql
CREATE TABLE tbl1 (col1 INT)  PARTITION BY HASH(col1) ;
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/100.basic-elements-of-mysql-mode/600.custom-variables-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/100.basic-elements-of-mysql-mode/600.custom-variables-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/400.functions-of-mysql-mode/200.single-row-functions-of-mysql-mode/400.mathematical-functions-of-mysql-mode/1600.generator-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/400.functions-of-mysql-mode/200.single-row-functions-of-mysql-mode/400.mathematical-functions-of-mysql-mode/1600.generator-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/1600.alter-table-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/1600.alter-table-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/2200.create-index-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/2200.create-index-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/2600.create-table-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/2600.create-table-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/5700.insert-sql-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/5700.insert-sql-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/5900.load-data-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/5900.load-data-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/8000.select-into-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/8000.select-into-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/8700.show-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/8700.show-of-mysql-mode.md)

### QUERY_TIMEOUT

**Purpose:** The `QUERY_TIMEOUT` hint specifies the execution timeout for the current query.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `QUERY_TIMEOUT` hint specifies the execution timeout for the current query.

**Syntax**


```sql
/*+ QUERY_TIMEOUT ( time_usec ) */
```


**Parameters**


- `time_usec`: specifies the query timeout, in microseconds.

**Examples**


```sql
-- Specifies the query timeout as 1 second. If the query does not complete within the specified timeout, a timeout error is returned.
SELECT /*+ QUERY_TIMEOUT(1000000) */ *
FROM employees e
WHERE e.department_id = 1001;
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

### READ_CONSISTENCY

**Purpose:** The `READ_CONSISTENCY` hint specifies the read consistency level for the current query.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `READ_CONSISTENCY` hint specifies the read consistency level for the current query.

**Syntax**


```sql
/*+ READ_CONSISTENCY(WEAK[STRONG]) */
```


**Parameters**


- `WEAK`: specifies to use weak consistency, which enables weak reads.

- `STRONG`: specifies to use strong consistency, which disables weak reads.

**Examples**


```sql
-- Uses the READ_CONSISTENCY hint and sets it to WEAK to enable weak reads for the query.
SELECT /*+ READ_CONSISTENCY(WEAK) */ *
FROM employees
WHERE employees.department_id = 1001;
```


Weak reads are supported when the isolation level is set to Repeatable Read or Serializable. Here is an example:

```sql
SET transaction read only;
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

### RESOURCE_GROUP

**Purpose:** The `RESOURCE_GROUP` hint forces the statement to use a specified resource group.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `RESOURCE_GROUP` hint forces the statement to use a specified resource group.

**Syntax**


The syntax of the `RESOURCE_GROUP` hint is as follows:

```sql
/*+ RESOURCE_GROUP ('resource_group_name') */
```


**Parameters**


- `resource_group_name`: specifies the name of the resource group to use.

**Examples**


Here is an example of using the `RESOURCE_GROUP` hint:

```shell
SELECT /*+ RESOURCE_GROUP('big_group') */ * FROM t1;
```


If the resource group `big_group` does not exist, the default resource group is used.

### STAT

**Purpose:** The `STAT` hint specifies to trace the output of specific operators in the query plan. After adding the `STAT` hint, the query plan will include a `MONITORING DUMP` operator. This operator directly outputs all data from the sort operator and prints the operator's execution time, number of output rows, and other information in the observer log after execution.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `STAT` hint specifies to trace the output of specific operators in the query plan.

After adding the `STAT` hint, the query plan will include a `MONITORING DUMP` operator. This operator directly outputs all data from the sort operator and prints the operator's execution time, number of output rows, and other information in the observer log after execution.

**Syntax**


```sql
/*+ STAT(TRACING_NUM_LIST) */
```


**Parameters**


- `TRACING_NUM_LIST`: specifies the IDs of the operators to trace.

**Examples**


```sql
-- Displays the changes in the execution plan before and after adding the hint `/*+ STAT(0, 2) */`
explain basic
SELECT /*+leading(t1) use_hash(t2)*/ * FROM t1, t2 WHERE t1.c1 = t2.c1;

Query Plan
```

### TRACING

**Purpose:** The `TRACING` hint specifies to trace the output of specific operators in the query plan. The usage of the `TRACING` hint, the plan after adding the hint, and the behavior when using the `STAT` hint are the same. The difference between using the `TRACING` hint and the `STAT` hint is that the `MONITORING DUMP` operator prints all its output data in the observer log when using the `TRACING` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `TRACING` hint specifies to trace the output of specific operators in the query plan.

The usage of the `TRACING` hint, the plan after adding the hint, and the behavior when using the `STAT` hint are the same.

The difference between using the `TRACING` hint and the `STAT` hint is that the `MONITORING DUMP` operator prints all its output data in the observer log when using the `TRACING` hint.

**Syntax**


```sql
/*+ TRACING(TRACING_NUM_LIST)*/
```


**Parameters**


- `TRACING_NUM_LIST`: specifies the IDs of the operators to trace.

**Examples**


```sql
-- Uses the TRACING hint and sets the level to 1 to enable tracing for the current query.
SELECT /*+ TRACING(1) */ *
FROM employees e
WHERE e.department_id = 1001;
```

### TRANS_PARAM

**Purpose:** The `TRANS_PARAM` hint is used to specify transaction-related parameters at the query level.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `TRANS_PARAM` hint is used to specify transaction-related parameters at the query level.

**Syntax**


```sql
/*+ TRANS_PARAM ['FORCE_EARLY_LOCK_FREE' , 'TRUE'] */
```


**Parameters**


Currently, only the `FORCE_EARLY_LOCK_FREE` parameter is supported, which specifies whether to enable early row lock release at the transaction level.

- `FORCE_EARLY_LOCK_FREE`: specifies whether to enable early row lock release at the transaction level. Valid values: **TRUE** (enables early row lock release) and **FALSE** (disables early row lock release).

**Notice**: The parameter name and value must be enclosed in single quotation marks ( ' '). If the parameter value is a number, you can omit the quotation marks.

**Examples**


```sql
-- Uses the TRANS_PARAM hint and sets the parameter 'FORCE_EARLY_LOCK_FREE' to 'TRUE' to enable early row lock release at the transaction level.
SELECT /*+ TRANS_PARAM('FORCE_EARLY_LOCK_FREE' 'TRUE') */ *
FROM employees e
WHERE e.department_id = 1001;
```

### USE_PLAN_CACHE

**Purpose:** The `USE_PLAN_CACHE` hint specifies the plan cache strategy for the current query. For more information about plan cache, see Execution plan cache.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `USE_PLAN_CACHE` hint specifies the plan cache strategy for the current query. For more information about plan cache, see [Execution plan cache](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/200.sql-execution-plan/300.execution-plan-cache.md).

**Syntax**


```sql
/*+ USE_PLAN_CACHE ( NONE | DEFAULT ) */
```


**Parameters**


- `NONE`: specifies that the query does not use the plan cache.

- `DEFAULT`: specifies that the current query uses the system variable [`ob_enable_plan_cache`](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/800.configuration-items-and-system-variables/200.system-variable/300.global-system-variable/7200.ob_enable_plan_cache-global.md) to control the plan cache strategy.

**Examples**


```sql
-- The following example specifies that the query does not use the plan cache when the `NONE` parameter is used, and uses the system variable `ob_enable_plan_cache` to control the plan cache strategy when the `DEFAULT` parameter is used.
SELECT /*+ USE_PLAN_CACHE(NONE) */ *
FROM employees e
WHERE e.department_id = 1001;

SELECT /*+ USE_PLAN_CACHE(DEFAULT) */ *
FROM employees e
WHERE e.department_id = 1001;
```

### USE_PX

**Purpose:** The `USE_PX` hint forces the server to use the PX (parallel execution) mode when executing an SQL statement. PX mode allows SQL statements to be executed using multiple threads, thereby improving query performance. Typically, the `USE_PX` hint is used together with the `PARALLEL` hint to specify the number of threads for parallel execution. By default, the system uses the `USE_PX` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Other

The `USE_PX` hint forces the server to use the PX (parallel execution) mode when executing an SQL statement. PX mode allows SQL statements to be executed using multiple threads, thereby improving query performance. Typically, the `USE_PX` hint is used together with the `PARALLEL` hint to specify the number of threads for parallel execution. By default, the system uses the `USE_PX` hint.

**Syntax**


The syntax of the `USE_PX` hint is as follows:

```sql
/*+ USE_PX */
```


**Examples**


The following example shows the use of the `USE_PX` hint:

```sql
SELECT /*+ USE_PX PARALLEL(4)*/ e.dept_id, sum(e.salary)
FROM emp e
WHERE e.dept_id = 1001 GROUP BY e.dept_id;
```

## Global > Transformation

### NO_COST_BASED_QUERY_TRANSFORMATION

**Purpose:** The `NO_COST_BASED_QUERY_TRANSFORMATION` hint disables cost-based query rewriting for the current query. For more information about cost-based query rewriting, see Cost-Based Query Rewriting.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/200.global-transform-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/200.global-transform-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Transformation

The `NO_COST_BASED_QUERY_TRANSFORMATION` hint disables cost-based query rewriting for the current query. For more information about cost-based query rewriting, see [Cost-Based Query Rewriting](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/500.query-rewrite/300.cost-based-query-rewriting.md).

**Syntax**


```sql
/*+ NO_COST_BASED_QUERY_TRANSFORMATION */
```


**Example**


```sql
-- Use the `NO_COST_BASED_QUERY_TRANSFORMATION` hint to disable cost-based query rewriting.
CREATE TABLE t1(c1 int, c2 int, c3 int, index idx1(c1), index idx2(c2));
SELECT /*+ NO_COST_BASED_QUERY_TRANSFORMATION */ *
FROM t1
WHERE c1 = 1 OR c2 = 1;
```

### NO_QUERY_TRANSFORMATION

**Purpose:** The `NO_QUERY_TRANSFORMATION` hint disables any query rewriting for the current query. Unlike the `NO_REWRITE` hint in Query Block Hints, using `NO_QUERY_TRANSFORMATION` prevents the use of Query Block Hints to enable certain rewritings. For more information about query rewriting, see Overview of Query Rewriting.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Global > Transformation; Global > Other.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/200.global-transform-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/200.global-transform-hints-of-oracle-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/100.global-hint-of-oracle-mode/300.other-global-hints-of-oracle-mode.md)

#### Documentation section 1: Global > Transformation

The `NO_QUERY_TRANSFORMATION` hint disables any query rewriting for the current query. Unlike the `NO_REWRITE` hint in Query Block Hints, using `NO_QUERY_TRANSFORMATION` prevents the use of Query Block Hints to enable certain rewritings.

For more information about query rewriting, see [Overview of Query Rewriting](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/500.query-rewrite/100.query-rewrite-overview.md).

**Syntax**


```sql
/*+ NO_QUERY_TRANSFORMATION */
```


**Example**


```sql
-- Use the `NO_QUERY_TRANSFORMATION` hint to disable any query rewriting.
SELECT /*+ NO_QUERY_TRANSFORMATION */ *
FROM (SELECT * FROM t1) v WHERE v.c1 = 3;
```

#### Documentation section 2: Global > Other

The `NO_QUERY_TRANSFORMATION` hint disables any query rewrite for the current query.

Note that unlike the `NO_REWRITE` hint in the Query Block Hint, using the `NO_QUERY_TRANSFORMATION` hint prevents you from enabling some rewrites through the Query Block Hint.

For more information about query rewrite, see [Overview of query rewrite](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/500.query-rewrite/100.query-rewrite-overview.md).

**Syntax**


```sql
/*+ NO_QUERY_TRANSFORMATION */
```


**Example**


The following query example uses the `NO_QUERY_TRANSFORMATION` hint to disable any query rewrite.

```sql
SELECT /*+ NO_QUERY_TRANSFORMATION */ *
FROM (SELECT * FROM t1) v WHERE v.c1 = 3;
```

## Outline

### OPTIMIZER_FEATURES_ENABLE

**Purpose:** The `OPTIMIZER_FEATURES_ENABLE` hint specifies the optimizer version used for the current query.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Outline.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/400.hints-related-to-outline-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/400.hints-related-to-outline-hints-of-oracle-mode.md)

#### Documentation section 1: Outline

The `OPTIMIZER_FEATURES_ENABLE` hint specifies the optimizer version used for the current query.

**Syntax**


```sql
/*+ OPTIMIZER_FEATURES_ENABLE ( version_number ) */
```


**Parameters**


- `version_number`: the optimizer version.

**Examples**


```sql
-- Use the OPTIMIZER_FEATURES_ENABLE hint to specify that the optimizer should use features from version 4.0.0.0 when generating the execution plan.
SELECT /*+ OPTIMIZER_FEATURES_ENABLE('4.0.0.0') */ employee_id, last_name
FROM employees
WHERE last_name = 'Smith';
```

### QB_NAME

**Purpose:** The `QB_NAME` hint allows you to specify a name for a query block, which can then be referenced in other hints. This is particularly useful when you need to apply more granular control to specific parts of a query. For more information, see Control query optimization using Query Block Name and QB_NAME Hint

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Outline.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/400.hints-related-to-outline-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/400.hints-related-to-outline-hints-of-oracle-mode.md)

#### Documentation section 1: Outline

The `QB_NAME` hint allows you to specify a name for a query block, which can then be referenced in other hints. This is particularly useful when you need to apply more granular control to specific parts of a query.

For more information, see [Control query optimization using Query Block Name and QB_NAME Hint](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/150.query-block-name-qb-hint-of-oracle-mode.md)

**Syntax**


```sql
/*+ QB_NAME(queryblock) */
```


**Parameters**


- `qb_name`: case-insensitive, cannot contain special characters, and has a maximum length of 20 characters.

**Considerations**


The `QB_NAME` hint is ineffective in the following scenarios:

- Specifying multiple valid `qb_name` values at the same query level.
- Specifying the same `qb_name` value at different query levels.

**Examples**


```sql
-- Use the QB_NAME hint to name the query block 'qb' and the FULL hint to force a full table scan on the employees table.
SELECT /*+ QB_NAME(qb) FULL(@qb e) */ employee_id, last_name
FROM employees e
WHERE last_name = 'Smith';
```

## Query block > Access path

### FULL

**Purpose:** The `FULL` Hint specifies that the optimizer scans the specified table by using the primary key.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Access path; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Access path

The `FULL` Hint specifies that the optimizer scans the specified table by using the primary key.

**Syntax**


```sql
/*+ FULL ( [ @queryblock ] tablespec ) */
```


**Examples**


The following example shows how to force the optimizer to scan the `employees` table by using the primary key. The query specifies the `last_name` column, which has an index. However, the optimizer scans the `employees` table by using the primary key. In the `FROM` clause, the `e` alias specifies the `employees` table. Therefore, the hint refers to the alias instead of the actual table name.

First, create the `employees` table and insert sample data and create an index:

```sql
CREATE TABLE hr.employees (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(255),
    first_name VARCHAR(255)
);

-- Insert some sample data
INSERT INTO hr.employees (employee_id, last_name, first_name)
VALUES
(1, 'Smith', 'John'),
(2, 'Doe', 'Jane'),
(3, 'Brown', 'Charlie');

-- Create an index
CREATE INDEX idx_last_name ON hr.employees(last_name);
```


Then, use the `FULL` Hint to force the optimizer to scan the `employees` table by using the primary key:

```sql
-- Force the optimizer to scan the employees table by using the primary key.
SELECT /*+ FULL(e) */ employee_id, last_name
FROM hr.employees e
WHERE last_name LIKE :al;
```

#### Documentation section 2: Shared optimizer guide

The syntax for the `FULL` hint is used to specify a full table scan for a table. The syntax is as follows:

```sql
/*+ FULL(table_name) */
```


The `FULL` hint is used to select a full table scan for the specified table, equivalent to the `INDEX` hint `/*+ INDEX(table_name PRIMARY) */`.

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

### INDEX

**Purpose:** The `INDEX` Hint specifies that the optimizer uses a specific index for the specified table. The reverse operation of this hint is the `NO_INDEX` Hint, which specifies that the optimizer disables a specific index for the specified table.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Access path; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Access path

The `INDEX` Hint specifies that the optimizer uses a specific index for the specified table. The reverse operation of this hint is the `NO_INDEX` Hint, which specifies that the optimizer disables a specific index for the specified table.

**Syntax**


```sql
/*+ INDEX ( [ @queryblock ] tablespec indexspec ) */
```


**Behavior**


The behavior of the hint depends on the `indexspec` specification:

- **Single index**: A hint can specify only one index. The optimizer considers only the specified index for scanning and ignores other indexes and full table scans.
- **Multiple hints**: You can specify multiple INDEX hints for the same table. For example, by using `/*+ INDEX(t idx1) INDEX(t idx2) */`, the optimizer evaluates the specified indexes and selects the one with the lowest cost for scanning. In this case, indexes not listed and full table scans are also ignored.

A single `INDEX` Hint can specify only one index. If you want to specify multiple indexes for the same table, you must write separate `INDEX` Hints for each index.

**Examples**


```sql
-- Use the INDEX Hint to specify that the optimizer uses the 'emp_department_ix' index to access the employees table.
SELECT /*+ INDEX (employees emp_department_ix) */ employee_id, department_id
FROM employees
WHERE department_id > 50;
```

#### Documentation section 2: Shared optimizer guide

The syntax of the `INDEX` hint is supported in both MySQL-compatible mode and Oracle-compatible mode.

* The syntax of the `INDEX` hint in Oracle-compatible mode is as follows:

```sql
SELECT/*+INDEX(table_name index_name) */ * FROM table_name;
```


* The syntax of the `INDEX` hint in MySQL-compatible mode is as follows:

```sql
table_name [[AS] alias] [index_hint_list]

index_hint_list:
index_hint [, index_hint] ...

index_hint:
USE {INDEX|KEY}
  [FOR {JOIN|ORDER BY|GROUP BY}] ([index_list])
  | IGNORE {INDEX|KEY}
  [FOR {JOIN|ORDER BY|GROUP BY}] (index_list)
  | FORCE {INDEX|KEY}
  [FOR {JOIN|ORDER BY|GROUP BY}] (index_list)

index_list:
index_name [, index_name] ...
```


In the syntax of Oracle-compatible mode, only one `INDEX` can be specified for a table, while in the MySQL-compatible mode, multiple indexes can be specified. However, in OceanBase Database's MySQL-compatible mode, although multiple `INDEX` hints can be specified, for the `USE` and `FORCE` methods, only the first `INDEX` is used to generate the `PATH`. Even if there is no `filter` for that `INDEX` in the SQL statement, leading to a full scan and table lookup, the current design of OceanBase Database assumes that the person writing the hint knows better which path is optimal. The `IGNORE` type will ignore all specified `INDEX` hints. The `USE` and `FORCE` methods function the same way as Oracle's hint mechanism. If the specified `INDEX` does not exist or is in an `invalid` state, the hint will be invalid. For the `IGNORE` method, if all `INDEX` hints, including the primary table, are ignored, the hint will also be invalid.

In SQL statements, if the table name has an alias, such as `table_name [AS] alias`, the alias must be used for the `INDEX` hint to take effect. An example is as follows:

```sql
create table t1(c1 int, c2 int, c3 int);
```


As shown in the preceding example, the filter condition `c1 = 1` is more effective than `c2 = 1`. If the `INDEX` hint is ineffective, the optimizer chooses the index `IDX1` based on the index selection mechanism.

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/2300.create-outline-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/2300.create-outline-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/2350.create-format-outline-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/2350.create-format-outline-of-mysql-mode.md)

### INDEX_MERGE

**Purpose:** The `INDEX_MERGE` hint is used to control the use of index merge plans for the specified table. If the specified index cannot generate an index merge plan, the hint is ignored. If no index is specified, the optimizer will attempt to generate an index merge plan as much as possible. Using the `INDEX_MERGE` hint can generate index merge plans even when the `_enable_index_merge` configuration parameter is set to `False`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Query block > Access path

The `INDEX_MERGE` hint is used to control the use of index merge plans for the specified table. If the specified index cannot generate an index merge plan, the hint is ignored. If no index is specified, the optimizer will attempt to generate an index merge plan as much as possible.

Using the `INDEX_MERGE` hint can generate index merge plans even when the `_enable_index_merge` configuration parameter is set to `False`.

**Syntax:**

```sql
/*+ INDEX_MERGE([@query_block_name] tbl_name [index_name [,index_name]...]) */
```


Parameters:

* `@query_block_name`: Optional. Specifies the name of the query block (query block) affected by the hint. If omitted, the default is to apply to the main query block of the current query.
* `tbl_name`: Specifies the name of the table to which the index merge plan should be applied.
* `index_name`: Optional. Specifies the name of the index involved in the index merge plan. Multiple index names can be specified.

  * If no `index_name` parameter is specified after the table name, it indicates that the index merge plan should be used for the specified table.
  * If an `index_name` parameter is specified after the table name, it indicates that the index merge plan should be generated using the specified index.

**Examples:**

* Specify the index name in the `INDEX_MERGE` hint.

```shell
SELECT /*+ INDEX_MERGE(t1 idx_c2 idx_c3) */ * FROM t1
        WHERE c2 = 1
        AND c3 = 1
        AND c4 = 1;
```


* Do not specify the index name in the `INDEX_MERGE` hint.

```shell
SELECT /*+ INDEX_MERGE(t1)*/ * FROM t1
        WHERE c2 = 1
        AND c3 = 1
        AND c4 = 1;
```

### INDEX_SS

**Purpose:** The `INDEX_SS` Hint specifies that the optimizer uses a specific index for index skip scan.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Query block > Access path

The `INDEX_SS` Hint specifies that the optimizer uses a specific index for index skip scan.

**Syntax**


```sql
/*+ INDEX_SS ( [ @ qb_name ] tablespec indexspec) */
```


**Parameters**


- `tablespec`: the table object specified by the hint.
- `indexspec`: the index used for index skip scan.

**Examples**


The following example shows how to specify that the optimizer uses the idx1 index for index skip scan. The query plan is as follows. The query range used for index skip scan is `(1,MIN ; 1,MAX)`, which is extracted from the second column c2 of the idx1 index.

```sql
create table t1(c1 int, c2 int ,c3 int);
create index idx1 on t1(c1, c2);
create index idx2 on t1(c2);
explain basic select /*+index_ss(t1 idx1)*/ 1 from t1 where c2 = 1;
```


Note that even if you use the `INDEX_SS` Hint, if the optimizer cannot extract the query range for index skip scan from the specified index, the query does not use index skip scan. In this case, the `INDEX_SS` Hint only specifies that the optimizer uses the specified index.

In the following two examples, the first query uses the idx1 index and extracts the query range `(1,MIN,MIN ; 1,MAX,MAX)`, which cannot be used for index skip scan. The second query uses the idx2 index and extracts the query range `(1,MIN ; 1,MAX)`, which also cannot be used for index skip scan.
In addition, there is no reverse hint to disable index skip scan for the `INDEX_SS` Hint. However, you can use the `INDEX` Hint to specify an index, which will directly disable index skip scan.

```sql
explain basic select /*+index_ss(t1 idx1)*/ 1 from t1 where c1 = 1;
```

### NO_INDEX

**Purpose:** The `NO_INDEX` Hint specifies that the optimizer disables a specific index for the specified table. The reverse operation of this hint is the `INDEX` Hint, which specifies that the optimizer uses a specific index for the specified table.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Query block > Access path

The `NO_INDEX` Hint specifies that the optimizer disables a specific index for the specified table. The reverse operation of this hint is the `INDEX` Hint, which specifies that the optimizer uses a specific index for the specified table.

**Syntax**


```sql
/*+ NO_INDEX ( [ @queryblock ] tablespec indexspec ) */
```


**Examples**


```sql
-- Use the NO_INDEX Hint to specify that the optimizer does not use the 'emp_department_ix' index to access the employees table.
SELECT /*+ NO_INDEX (employees emp_department_ix) */ employee_id, department_id
FROM employees
WHERE department_id > 50;
```

### NO_INDEX_MERGE

**Purpose:** The `NO_INDEX_MERGE` hint is used to control the use of the specified index to generate an index merge plan for the specified table. If no index is specified, the optimizer will not generate an index merge plan for the table. When the `NO_INDEX_MERGE` hint and the `INDEX_MERGE` hint conflict, both hints are ignored.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Query block > Access path

The `NO_INDEX_MERGE` hint is used to control the use of the specified index to generate an index merge plan for the specified table. If no index is specified, the optimizer will not generate an index merge plan for the table.

When the `NO_INDEX_MERGE` hint and the `INDEX_MERGE` hint conflict, both hints are ignored.

**Syntax:**

```sql
/*+ NO_INDEX_MERGE([@query_block_name] tbl_name [index_name [,index_name]...]) */
```


Parameters:

* `@query_block_name`: Optional. Specifies the name of the query block (query block) affected by the hint. If omitted, the default is to apply to the main query block of the current query.
* `tbl_name`: Specifies the name of the table.
* `index_name`: Optional. Specifies the name of the index. Multiple index names can be specified.

  * If no `index_name` parameter is specified after the table name, it indicates that the index merge plan should not be used.
  * If an `index_name` parameter is specified after the table name, it indicates that the index merge plan should not be generated using the specified index.

**Examples:**

```shell
SELECT /*+ NO_INDEX_MERGE(t1)*/ * FROM t1
    WHERE c2 = 1
    AND c3 = 1
    AND c4 = 1;
```

### NO_USE_COLUMN_TABLE

**Purpose:** The `NO_USE_COLUMN_TABLE` hint specifies that columnar scanning should not be used for the table object.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Query block > Access path

The `NO_USE_COLUMN_TABLE` hint specifies that columnar scanning should not be used for the table object.

**Syntax**


```sql
/*+ NO_USE_COLUMN_TABLE ( [ @ qb_name ] tablespec ) */
```


**Examples**


```sql
create table t(c1 int, c2 int ,c3 int)
with column group (all columns, each column);

explain basic select /*+NO_USE_COLUMN_TABLE(t)*/ * from t;
```

### NO_USE_DAS

**Purpose:** The `NO_USE_DAS` hint instructs the optimizer to not use DAS when processing queries on the specified table. Its opposite operation is `USE_DAS`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Query block > Access path

The `NO_USE_DAS` hint instructs the optimizer to not use DAS when processing queries on the specified table. Its opposite operation is `USE_DAS`.

**Syntax**


```sql
/*+ NO_USE_DAS ( [ @queryblock ] tablespec ) */
```


**Examples**


```sql
-- The `NO_USE_DAS` hint instructs the optimizer not to perform dynamic adaptive sampling on table t1, but to execute the query based on existing statistics.
SELECT /*+ NO_USE_DAS(t1) */ * FROM t1 WHERE column1 < 50;
```

### USE_COLUMN_TABLE

**Purpose:** The `USE_COLUMN_TABLE` hint specifies that columnar scanning should be used for the table object. For tables that have not enabled columnar storage, this hint is ineffective.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Query block > Access path

The `USE_COLUMN_TABLE` hint specifies that columnar scanning should be used for the table object. For tables that have not enabled columnar storage, this hint is ineffective.

**Syntax**


```sql
/*+ USE_COLUMN_TABLE ( [ @ qb_name ] tablespec) */
```


**Examples**


```sql
create table t(c1 int, c2 int ,c3 int)
with column group (all columns, each column);

explain basic select /*+USE_COLUMN_TABLE(t)*/ * from t;
```

### USE_DAS

**Purpose:** The `USE_DAS` hint instructs the optimizer to use the Distributed Data Access Service (DAS) for the specified table. DAS is a distributed data access service provided by OceanBase Database. By enabling the `USE_DAS` hint, users can leverage the following features to fully utilize the advantages of OceanBase Database: 1. **Partition pruning capability**: DAS maintains the mapping between data and physical nodes, allowing the optimizer to calculate the required physical location information during SQL execution. This improves query efficiency and reduces unnecessary data scans. 2. **Efficient base data access**: DAS supports common database operations such as insert, update, delete, lock_row, and scan. It ensures efficient data access across distributed environments, allowing SQL requests to flexibly access data from any observer node within the cluster. 3. **Task-level retry capability**: During data access, if certain partitions become unreadable due to replica migration or network partitioning, DAS automatically retries the request from other available replicas.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Access path.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/100.the-hint-related-to-the-access-path-of-oracle-mode.md)

#### Documentation section 1: Query block > Access path

The `USE_DAS` hint instructs the optimizer to use the Distributed Data Access Service (DAS) for the specified table. DAS is a distributed data access service provided by OceanBase Database. By enabling the `USE_DAS` hint, users can leverage the following features to fully utilize the advantages of OceanBase Database:

1. **Partition pruning capability**: DAS maintains the mapping between data and physical nodes, allowing the optimizer to calculate the required physical location information during SQL execution. This improves query efficiency and reduces unnecessary data scans.

2. **Efficient base data access**: DAS supports common database operations such as insert, update, delete, lock_row, and scan. It ensures efficient data access across distributed environments, allowing SQL requests to flexibly access data from any observer node within the cluster.

3. **Task-level retry capability**: During data access, if certain partitions become unreadable due to replica migration or network partitioning, DAS automatically retries the request from other available replicas.

**Syntax**


```sql
/*+ USE_DAS ( [ @queryblock ] tablespec ) */
```


**Examples**


```sql
SELECT /*+ USE_DAS(t1) */ * FROM t1 WHERE column1 > 100;
```

**MySQL-mode evidence:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/100.basic-elements-of-mysql-mode/600.custom-variables-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/100.basic-elements-of-mysql-mode/600.custom-variables-of-mysql-mode.md)

## Query block > Cost-based transformation

### COALESCE_SQ

**Purpose:** `COALESCE_SQ` Hint specifies to merge subqueries in the query. The reverse operation is `NO_COALESCE_SQ` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`COALESCE_SQ` Hint specifies to merge subqueries in the query. The reverse operation is `NO_COALESCE_SQ` Hint.

**Syntax**


```sql
/*+ COALESCE_SQ [ ( [ @ qb_name ] [ qb_name_list ] ) ] */
```


**Parameters**


- `qb_name_list`: Optional. Specifies the name list of one or more query blocks. You can specify to merge subqueries in specific query blocks. If this parameter is not specified, the hint specifies to merge all possible subqueries.

**Examples**


The following query example specifies to merge only the subqueries in `SEL1` and `SEL2`.

```sql
UPDATE /*+ COALESCE_SQ(("SEL1", "SEL2")) */ t1
SET c1 = (SELECT /*+ QB_NAME(SEL1) */ c1 FROM t2 A),
    c2 = (SELECT /*+ QB_NAME(SEL2) */ c2 FROM t2 B),
    c3 = (SELECT /*+ QB_NAME(SEL3) */ c3 FROM t2 C),
    c4 = (SELECT /*+ QB_NAME(SEL4) */ c4 FROM t2 D);
```

### MERGE

**Purpose:** `MERGE` Hint specifies to enable view merging. The reverse operation is `NO_MERGE` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`MERGE` Hint specifies to enable view merging. The reverse operation is `NO_MERGE` Hint.

**Syntax**


```sql
/*+ MERGE [ ( [ @ qb_name ] [ > upper_qb_name ] ) ] */
```


**Parameters**


- `upper_qb_name`: Optional. Specifies the specific form of view merging. We recommend that you use the default value.

**Examples**


The following query example specifies to enable subquery view merging. The `MERGE` Hint and `NO_REWRITE` Hint are used together to force the optimizer to merge views and disable other types of query rewriting.

```sql
SELECT * FROM (SELECT /*+ MERGE NO_REWRITE */ * FROM t1);
```

### NO_COALESCE_SQ

**Purpose:** `NO_COALESCE_SQ` Hint specifies to disable subquery merging. The reverse operation is `COALESCE_SQ` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`NO_COALESCE_SQ` Hint specifies to disable subquery merging. The reverse operation is `COALESCE_SQ` Hint.

**Syntax**


```sql
/*+ NO_COALESCE_SQ [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `qb_name`: Optional. Specifies to disable subquery merging in specific query blocks. If this parameter is not specified, the hint specifies to disable subquery merging in all possible subqueries.

**Examples**


The following query example specifies to disable subquery merging to maintain the original query structure.

```sql
UPDATE /*+ NO_COALESCE_SQ */ t1
SET c1 = (SELECT /*+ QB_NAME(SEL1) */ c1 FROM t2 A),
    c2 = (SELECT /*+ QB_NAME(SEL2) */ c2 FROM t2 B),
    c3 = (SELECT /*+ QB_NAME(SEL3) */ c3 FROM t2 C),
    c4 = (SELECT /*+ QB_NAME(SEL4) */ c4 FROM t2 D);
```

### NO_EXPAND

**Purpose:** `NO_EXPAND` Hint specifies to disable query expansion for `WHERE` clauses containing `OR` conditions. The reverse operation is `USE_CONCAT` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`NO_EXPAND` Hint specifies to disable query expansion for `WHERE` clauses containing `OR` conditions. The reverse operation is `USE_CONCAT` Hint.

**Syntax**


```sql
/*+ NO_EXPAND [ ( [ @ qb_name ] ) ] */
```


**Examples**


```sql
-- Use the NO_EXPAND Hint to instruct the optimizer to not expand queries containing OR conditions.
SELECT /*+ NO_EXPAND */ *
  FROM employees e, departments d
  WHERE e.manager_id = 108
     OR d.department_id = 110;
```

### NO_MERGE

**Purpose:** `NO_MERGE` Hint specifies to disable view merging. The reverse operation is `MERGE` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`NO_MERGE` Hint specifies to disable view merging. The reverse operation is `MERGE` Hint.

**Syntax**


```sql
/*+ NO_MERGE [ ( [ @ qb_name ] ) ] */
```


**Examples**


The following query example specifies to disable subquery view merging.

```sql
SELECT * FROM (SELECT /*+ NO_MERGE */ * FROM t1);
```

### NO_PLACE_GROUP_BY

**Purpose:** `NO_PLACE_GROUP_BY` Hint specifies to disable `GROUP BY` pushing down. The reverse operation is `PLACE_GROUP_BY` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`NO_PLACE_GROUP_BY` Hint specifies to disable `GROUP BY` pushing down. The reverse operation is `PLACE_GROUP_BY` Hint.

**Syntax**


```sql
/*+ NO_PLACE_GROUP_BY [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example specifies to perform the `GROUP BY` operation at the original query level without any rewriting.

```sql
SELECT /*+ NO_PLACE_GROUP_BY */ SUM(t2.c3)
FROM t1
JOIN t2 ON t1.c2 = t2.c2
GROUP BY t1.c2;
```

### NO_SEMI_TO_INNER

**Purpose:** The `NO_SEMI_TO_INNER` hint disables the conversion of semi-join queries to inner join queries. The reverse operation is the `SEMI_TO_INNER` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

The `NO_SEMI_TO_INNER` hint disables the conversion of semi-join queries to inner join queries. The reverse operation is the `SEMI_TO_INNER` hint.

**Syntax**


```sql
/*+ NO_SEMI_TO_INNER [ ( [ @ qb_name ]  ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example uses the `NO_SEMI_TO_INNER` hint to ensure that the optimizer does not attempt to convert the semi-join in the `EXISTS` clause to an inner join when deriving the result set.

```sql
SELECT /*+ NO_SEMI_TO_INNER */ *
FROM t1
WHERE EXISTS (SELECT 1 FROM t2 WHERE t1.c1 = t2.c2);
```

### NO_WIN_MAGIC

**Purpose:** The `NO_WIN_MAGIC` hint disables the `WIN MAGIC` query rewrite. The reverse operation is the `WIN_MAGIC` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

The `NO_WIN_MAGIC` hint disables the `WIN MAGIC` query rewrite. The reverse operation is the `WIN_MAGIC` hint.

**Syntax**


```sql
/*+ NO_WIN_MAGIC [ ( [ @ qb_name ] ) ] */
```


**Examples**


The following query example uses the `NO_WIN_MAGIC` hint to keep the query unchanged, avoiding any rewrites using window functions.

```sql
SELECT /*+ NO_WIN_MAGIC */ *
FROM t1
JOIN (SELECT AVG(c1), c2 FROM t1 GROUP BY c2) v ON t1.c2 = v.c2
ORDER BY t1.pk;
```

### PLACE_GROUP_BY

**Purpose:** `PLACE_GROUP_BY` Hint specifies to enable `GROUP BY` pushing down. This can reduce the amount of data that needs to be grouped and aggregated in some cases. The reverse operation is `NO_PLACE_GROUP_BY` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`PLACE_GROUP_BY` Hint specifies to enable `GROUP BY` pushing down. This can reduce the amount of data that needs to be grouped and aggregated in some cases. The reverse operation is `NO_PLACE_GROUP_BY` Hint.

**Syntax**


```sql
/*+ PLACE_GROUP_BY [ ( [ @ qb_name ] [ ( table_list ) ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.
- `table_list`: Optional. Specifies to push down `GROUP BY` for specific joined tables. If this parameter is not specified, the hint specifies to attempt to push down `GROUP BY` for all joined tables.

**Examples**


The following query example specifies to attempt to process the `GROUP BY` clause at a more optimal position in the execution plan.

```sql
SELECT /*+ PLACE_GROUP_BY */ SUM(t2.c3)
FROM t1
JOIN t2 ON t1.c2 = t2.c2
GROUP BY t1.c2;
```

### SEMI_TO_INNER

**Purpose:** `SEMI_TO_INNER` Hint specifies to enable semi-join queries containing `EXISTS` or `IN` clauses to be converted to inner join queries. The reverse operation is `NO_SEMI_TO_INNER` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`SEMI_TO_INNER` Hint specifies to enable semi-join queries containing `EXISTS` or `IN` clauses to be converted to inner join queries. The reverse operation is `NO_SEMI_TO_INNER` Hint.

**Syntax**


```sql
/*+ SEMI_TO_INNER [ ( [ @ qb_name ] [ table ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.
- `table`: Optional. Specifies the right table of the semi-join to rewrite specific semi-joins. If this parameter is not specified, the hint specifies to rewrite all semi-joins. We recommend that you do not specify this parameter when you use the hint.

**Examples**


The following query example specifies to attempt to convert the semi-join between t1 and t2 to an inner join.

```sql
SELECT /*+ SEMI_TO_INNER(t2) */ *
FROM t1
WHERE EXISTS (SELECT 1 FROM t2 WHERE t1.c1 = t2.c2);
```

### USE_CONCAT

**Purpose:** `USE_CONCAT` Hint specifies to enable query expansion for `WHERE` clauses containing `OR` conditions. The reverse operation is `NO_EXPAND` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

`USE_CONCAT` Hint specifies to enable query expansion for `WHERE` clauses containing `OR` conditions. The reverse operation is `NO_EXPAND` Hint.

**Syntax**


```sql
/*+ USE_CONCAT [ ( [ @ qb_name ] [ expand_cond_str ] ) ] */
```


**Parameters**


- `expand_cond_str`: Optional. Specifies to expand only specific `OR` conditions. If this parameter is not specified, the hint specifies to expand all `OR` conditions.

**Examples**


- Example 1: Apply the `USE_CONCAT` Hint to the first `OR` condition.

```sql
SELECT /*+ USE_CONCAT('b.c1 = c.c1 OR b.c2 = c.c2') */ a.c1, b.c1, c.c1
FROM t1 a
LEFT JOIN (t1 b LEFT JOIN t1 c ON b.c3 = 4 AND (b.c1 = c.c1 OR b.c2 = c.c2))
ON a.c1 = b.c1
WHERE (a.c2 = 3 OR a.c3 = 4)
  AND EXISTS (SELECT * FROM t1 d WHERE a.c1 = d.c1 OR a.c2 = d.c2);
```


- Example 2: Apply the `USE_CONCAT` Hint to the second `OR` condition.

```sql
SELECT /*+ USE_CONCAT('a.c2 = 3 OR a.c3 = 4') */ a.c1, b.c1, c.c1
FROM t1 a
LEFT JOIN (t1 b LEFT JOIN t1 c ON b.c3 = 4 AND (b.c1 = c.c1 OR b.c2 = c.c2))
ON a.c1 = b.c1
WHERE (a.c2 = 3 OR a.c3 = 4)
  AND EXISTS (SELECT * FROM t1 d WHERE a.c1 = d.c1 OR a.c2 = d.c2);
```


- Example 3: Apply the `USE_CONCAT` Hint to the `OR` condition in the `EXISTS` clause.

```sql
SELECT /*+ USE_CONCAT('a.c1 = VIEW1.d.c1 OR a.c2 = VIEW1.d.c2') */ a.c1, b.c1, c.c1
FROM t1 a
LEFT JOIN (t1 b LEFT JOIN t1 c ON b.c3 = 4 AND (b.c1 = c.c1 OR b.c2 = c.c2))
ON a.c1 = b.c1
WHERE (a.c2 = 3 OR a.c3 = 4)
  AND EXISTS (SELECT * FROM t1 d WHERE a.c1 = d.c1 OR a.c2 = d.c2);
```

### WIN_MAGIC

**Purpose:** The `WIN_MAGIC` hint enables the `WIN MAGIC` query rewrite, which eliminates joins in specific scenarios and uses window functions for optimization. This hint instructs the optimizer to remove unnecessary joins and replace them with window functions, improving query execution efficiency. The reverse operation is the `NO_WIN_MAGIC` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Cost-based transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/200.hints-related-to-cost-based-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Cost-based transformation

The `WIN_MAGIC` hint enables the `WIN MAGIC` query rewrite, which eliminates joins in specific scenarios and uses window functions for optimization. This hint instructs the optimizer to remove unnecessary joins and replace them with window functions, improving query execution efficiency. The reverse operation is the `NO_WIN_MAGIC` hint.

**Syntax**


```sql
/*+ WIN_MAGIC [ ( [ @ qb_name ] [ table_list ] ) ] */
```


**Parameters**


- `table_list`: Optional. Specifies which tables should participate in the `WIN_MAGIC` query rewrite. If this parameter is omitted, the hint applies to all tables.

**Examples**


The following query example uses `WIN_MAGIC(t1 v)` to instruct the optimizer to apply window functions to optimize processing for table t1 and derived table v.

```sql
SELECT /*+ WIN_MAGIC(t1 v) */ *
FROM t1
JOIN (SELECT AVG(c1), c2 FROM t1 GROUP BY c2) v ON t1.c2 = v.c2
ORDER BY t1.pk;
```

## Query block > DISTINCT

### DISTINCT_PUSHDOWN

**Purpose:** The `DISTINCT_PUSHDOWN` hint instructs the optimizer to push down the `DISTINCT` operation during distributed execution, allowing for local deduplication at each partition node. Its reverse operation is the `NO_DISTINCT_PUSHDOWN` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > DISTINCT.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/600.hints-related-to-distinct-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/600.hints-related-to-distinct-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > DISTINCT

The `DISTINCT_PUSHDOWN` hint instructs the optimizer to push down the `DISTINCT` operation during distributed execution, allowing for local deduplication at each partition node. Its reverse operation is the `NO_DISTINCT_PUSHDOWN` hint.

**Syntax**


```sql
/*+ DISTINCT_PUSHDOWN [ ( [ @ qb_name ] ) ] */
```


**Examples**


The following query example demonstrates how to use the `DISTINCT_PUSHDOWN` hint to enable the pushdown of the `DISTINCT` operation during distributed execution. If no hint is specified, the default behavior is to push down the `DISTINCT` operation.

```sql
-- Use the `DISTINCT_PUSHDOWN` hint to push down the `DISTINCT` operation to each partition node during distributed query execution.
CREATE TABLE tp1(c1 INT, c2 INT, c3 INT) PARTITION BY HASH(c1) PARTITIONS 10;
EXPLAIN BASIC SELECT /*+ DISTINCT_PUSHDOWN */ DISTINCT c2, c3 FROM tp1;
```

### NO_DISTINCT_PUSHDOWN

**Purpose:** The `NO_DISTINCT_PUSHDOWN` hint prevents the optimizer from pushing down the `DISTINCT` operation during distributed execution. Its reverse operation is the `DISTINCT_PUSHDOWN` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > DISTINCT.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/600.hints-related-to-distinct-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/600.hints-related-to-distinct-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > DISTINCT

The `NO_DISTINCT_PUSHDOWN` hint prevents the optimizer from pushing down the `DISTINCT` operation during distributed execution. Its reverse operation is the `DISTINCT_PUSHDOWN` hint.

**Syntax**


```sql
/*+ NO_DISTINCT_PUSHDOWN [ ( [ @ qb_name ] ) ] */
```


**Example**


The following query example shows how to use the `NO_DISTINCT_PUSHDOWN` hint to prevent the optimizer from pushing down the `DISTINCT` operation during distributed execution.

```sql
-- Use the NO_DISTINCT_PUSHDOWN hint to prevent the optimizer from pushing down the DISTINCT operation during distributed execution.
CREATE TABLE tp1(c1 INT, c2 INT, c3 INT) PARTITION BY HASH(c1) PARTITIONS 10;
EXPLAIN BASIC SELECT /*+ NO_DISTINCT_PUSHDOWN */ DISTINCT c2, c3 FROM tp1;
```

### NO_USE_HASH_DISTINCT

**Purpose:** The `NO_USE_HASH_DISTINCT` Hint disables the specific algorithm used for executing the distinct operation. Its reverse operation is the `USE_HASH_DISTINCT` Hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > DISTINCT.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/600.hints-related-to-distinct-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/600.hints-related-to-distinct-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > DISTINCT

The `NO_USE_HASH_DISTINCT` Hint disables the specific algorithm used for executing the distinct operation. Its reverse operation is the `USE_HASH_DISTINCT` Hint.

**Syntax**


```sql
/*+ NO_USE_HASH_DISTINCT [ ( [ @ qb_name ] ) ] */
```


**Examples**


The following query example uses the `NO_USE_HASH_DISTINCT` Hint to ensure that the optimizer does not use the `HASH` algorithm for the `DISTINCT` operation but instead uses the `MERGE` algorithm. Since OceanBase Database supports both the `HASH` and `MERGE` algorithms for deduplication, using the `NO_USE_HASH_DISTINCT` Hint results in the use of the `MERGE` algorithm.

```sql
-- Use the `NO_USE_HASH_DISTINCT` Hint to ensure that the `MERGE` algorithm is used for the `DISTINCT` operation instead of the `HASH` algorithm.
EXPLAIN BASIC SELECT /*+ NO_USE_HASH_DISTINCT */ DISTINCT c1, c2, c3 FROM t1;
```

### USE_HASH_DISTINCT

**Purpose:** The `USE_HASH_DISTINCT` hint enables the optimizer to use the `HASH` algorithm for the `DISTINCT` operation. Its reverse operation is the `NO_USE_HASH_DISTINCT` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > DISTINCT.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/600.hints-related-to-distinct-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/600.hints-related-to-distinct-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > DISTINCT

The `USE_HASH_DISTINCT` hint enables the optimizer to use the `HASH` algorithm for the `DISTINCT` operation. Its reverse operation is the `NO_USE_HASH_DISTINCT` hint.

**Syntax**


```sql
/*+ USE_HASH_DISTINCT [ ( [ @ qb_name ] ) ] */
```


**Examples**


The following query example shows how to use the `USE_HASH_DISTINCT` hint to enable the `HASH` deduplication algorithm.

```sql
-- Use the `USE_HASH_DISTINCT` hint to make the query use the `HASH` algorithm for the `DISTINCT` operation.
EXPLAIN BASIC SELECT /*+ USE_HASH_DISTINCT */ DISTINCT c1, c2, c3 FROM t1;
| Query Plan                                                        |
```

## Query block > Distributed DML

### NO_USE_DISTRIBUTED_DML

**Purpose:** The `NO_USE_DISTRIBUTED_DML` hint disables distributed DML execution. Its reverse is the `USE_DISTRIBUTED_DML` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Distributed DML.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/800.hints-related-to-distributed-dml-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/800.hints-related-to-distributed-dml-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Distributed DML

The `NO_USE_DISTRIBUTED_DML` hint disables distributed DML execution. Its reverse is the `USE_DISTRIBUTED_DML` hint.

**Syntax**


```sql
/*+ NO_USE_DISTRIBUTED_DML [ ( [ @ qb_name ] ) ] */
```


**Examples**


```sql
-- Create a table tp1 with 10 hash partitions.
CREATE TABLE tp1(c1 INT, c2 INT, c3 INT) PARTITION BY HASH(c1) PARTITIONS 10;

-- Use the NO_USE_DISTRIBUTED_DML hint to restrict the update operation to be performed locally on a single node, rather than distributed.
-- This update operation will be executed non-distributedly.
EXPLAIN BASIC UPDATE /*+ NO_USE_DISTRIBUTED_DML */ tp1 SET c2 = 4 WHERE c1 < 4;
```

### USE_DISTRIBUTED_DML

**Purpose:** The `USE_DISTRIBUTED_DML` hint enables distributed DML operations. When this hint is enabled, DML operations are executed in a distributed manner. The opposite of this hint is `NO_USE_DISTRIBUTED_DML`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Distributed DML.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/800.hints-related-to-distributed-dml-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/800.hints-related-to-distributed-dml-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Distributed DML

The `USE_DISTRIBUTED_DML` hint enables distributed DML operations. When this hint is enabled, DML operations are executed in a distributed manner. The opposite of this hint is `NO_USE_DISTRIBUTED_DML`.

**Syntax**


```sql
/*+ USE_DISTRIBUTED_DML [ ( [ @ qb_name ] ) ] */
```


**Examples**


```sql
-- Create a table named tp1 with 10 hash partitions.
CREATE TABLE tp1(c1 INT, c2 INT, c3 INT) PARTITION BY HASH(c1) PARTITIONS 10;

-- Use the USE_DISTRIBUTED_DML hint to update the tp1 table, setting the value of column c2 to 4 where the value of column c1 is less than 4.
-- This update operation will be distributed.
EXPLAIN BASIC UPDATE /*+ USE_DISTRIBUTED_DML */ tp1 SET c2 = 4 WHERE c1 < 4;
```

## Query block > GROUP BY

### DISABLE_OP_RICH_FORMAT

**Purpose:** The `DISABLE_OP_RICH_FORMAT` hint is used to roll back the physical operators specified in `op_list` to vectorized 1.0 in the plan.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > GROUP BY.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > GROUP BY

The `DISABLE_OP_RICH_FORMAT` hint is used to roll back the physical operators specified in `op_list` to vectorized 1.0 in the plan.

**Syntax**


```sql
hint: disable_op_rich_format(op_list);

opt_list: op_name | op_list,op_name

op_name:
LIMIT
| MERGE_DISTINCT
| HASH_DISTINCT
| MATERIAL
| MERGE_JOIN
| GRANULE_ITERATOR
| EXPAND
| SORT
| HASH_UNION
| HASH_INTERSECT
| HASH_EXCEPT
| MERGE_UNION
| MERGE_INTERSECT
| MERGE_EXCEPT
| TABLE_SCAN
| HASH_JOIN
| NESTED_LOOP_JOIN
| SUBPLAN_FILTER
| SUBPLAN_SCAN
| UNPIVOT
| SCALAR_AGGREGATE
| MERGE_GROUP_BY
| HASH_GROUP_BY
| WINDOW_FUNCTION
```


**Example**


```shell
SELECT /*+disable_op_rich_format('table_scan','hash_group_by')*/ * FROM t GROUP BY a;
```

### GBY_PUSHDOWN

**Purpose:** The `GBY_PUSHDOWN` hint instructs the optimizer to push down the `GROUP BY` operation to the data nodes in the distributed database when possible. This way, each node can perform grouping and aggregation on its portion of the data and then send the results to a central node for the final aggregation. Its reverse operation is `NO_GBY_PUSHDOWN`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > GROUP BY.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > GROUP BY

The `GBY_PUSHDOWN` hint instructs the optimizer to push down the `GROUP BY` operation to the data nodes in the distributed database when possible. This way, each node can perform grouping and aggregation on its portion of the data and then send the results to a central node for the final aggregation. Its reverse operation is `NO_GBY_PUSHDOWN`.

**Syntax**


```sql
/*+ GBY_PUSHDOWN([qb_name]) */
```


**Example**


```sql
SELECT /*+ GBY_PUSHDOWN */ department_id, COUNT(*) as emp_count
FROM employees
GROUP BY department_id;
```

### NO_GBY_PUSHDOWN

**Purpose:** The `NO_GBY_PUSHDOWN` hint is the opposite of the `GBY_PUSHDOWN` hint. It instructs the optimizer not to push down the `GROUP BY` operation to the data nodes, but instead to perform the entire grouping and aggregation process at the central node. Its reverse operation is `GBY_PUSHDOWN`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > GROUP BY.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > GROUP BY

The `NO_GBY_PUSHDOWN` hint is the opposite of the `GBY_PUSHDOWN` hint. It instructs the optimizer not to push down the `GROUP BY` operation to the data nodes, but instead to perform the entire grouping and aggregation process at the central node. Its reverse operation is `GBY_PUSHDOWN`.

**Syntax**


```sql
/*+ NO_GBY_PUSHDOWN([qb_name]) */
```


**Example**


```sql
SELECT /*+ NO_GBY_PUSHDOWN */ department_id, COUNT(*) as emp_count
FROM employees
GROUP BY department_id;
```

### NO_USE_HASH_AGGREGATION

**Purpose:** The `NO_USE_HASH_AGGREGATION` hint instructs the optimizer to avoid using the hash aggregation algorithm when executing the SQL statement. It sets GROUPBY/DISTINCT to not use HASH AGGREGATE, but instead use MERGE GROUP BY and MERGE DISTINCT. Its reverse operation is `USE_HASH_AGGREGATION`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > GROUP BY.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > GROUP BY

The `NO_USE_HASH_AGGREGATION` hint instructs the optimizer to avoid using the hash aggregation algorithm when executing the SQL statement. It sets GROUPBY/DISTINCT to not use HASH AGGREGATE, but instead use MERGE GROUP BY and MERGE DISTINCT. Its reverse operation is `USE_HASH_AGGREGATION`.

**Syntax**


```sql
/*+ NO_USE_HASH_AGGREGATION([qb_name]) */
```


**Example**


```sql
-- Use the NO_USE_HASH_AGGREGATION hint to instruct the query optimizer to avoid using the hash aggregation algorithm.
-- The optimizer will choose other aggregation methods, such as sorted aggregation, to calculate the sum of salaries for e.department_id.
SELECT /*+ NO_USE_HASH_AGGREGATION */ e.department_id, sum(e.salary)
FROM employees e
WHERE e.department_id = 1001
GROUP BY e.department_id;
```

### USE_HASH_AGGREGATION

**Purpose:** The `USE_HASH_AGGREGATION` hint instructs the optimizer to force the use of the `HASH` aggregation algorithm when generating a plan for the SQL statement. It sets `GROUP BY`/`DISTINCT` to use HASH AGGREGATE, such as HASH `GROUP BY` and HASH `DISTINCT`. Its reverse operation is `NO_USE_HASH_AGGREGATION`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > GROUP BY.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/500.hints-related-to-the-groupby-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > GROUP BY

The `USE_HASH_AGGREGATION` hint instructs the optimizer to force the use of the `HASH` aggregation algorithm when generating a plan for the SQL statement. It sets `GROUP BY`/`DISTINCT` to use HASH AGGREGATE, such as HASH `GROUP BY` and HASH `DISTINCT`. Its reverse operation is `NO_USE_HASH_AGGREGATION`.

**Syntax**


```sql
/*+USE_HASH_AGGREGATION([qb_name]) */
```


**Example**


```sql
-- Use the USE_HASH_AGGREGATION hint to force the query optimizer to use the hash aggregation algorithm for aggregate calculations.
-- In this query, this means that the sum of salaries will be calculated using a hash table after grouping by e.department_id.
SELECT /*+ USE_HASH_AGGREGATION */ e.department_id, sum(e.salary)
FROM employees e
WHERE e.department_id = 1001
GROUP BY e.department_id;
```

## Query block > Heuristic transformation

### AGGR_FIRST_UNNEST

**Purpose:** The `AGGR_FIRST_UNNEST` hint makes the optimizer prioritize independent aggregation calculations over merging them into the main query when handling subqueries with aggregate functions. Its reverse operation is the `NO_AGGR_FIRST_UNNEST` hint. It is not recommended to directly use the `AGGR_FIRST_UNNEST` or `NO_AGGR_FIRST_UNNEST` hints because they directly affect the rewriting behavior of subquery lifting. Generally, if you need more basic control over subquery lifting behavior, it is recommended to use the `UNNEST` or `NO_UNNEST` hints instead.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `AGGR_FIRST_UNNEST` hint makes the optimizer prioritize independent aggregation calculations over merging them into the main query when handling subqueries with aggregate functions. Its reverse operation is the `NO_AGGR_FIRST_UNNEST` hint.

It is not recommended to directly use the `AGGR_FIRST_UNNEST` or `NO_AGGR_FIRST_UNNEST` hints because they directly affect the rewriting behavior of subquery lifting. Generally, if you need more basic control over subquery lifting behavior, it is recommended to use the `UNNEST` or `NO_UNNEST` hints instead.

**Syntax**


```sql
/*+ AGGR_FIRST_UNNEST [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


In the following example, the `AGGR_FIRST_UNNEST` hint is used to enable aggregation in subqueries, prioritizing subquery lifting during query rewriting.

```sql
-- The hint directs the optimizer to prioritize lifting the AVG aggregate function from the subquery during query parsing.
SELECT * FROM t1
WHERE t1.c1 > (SELECT /*+ AGGR_FIRST_UNNEST */ AVG(d1)
               FROM t2
               WHERE t1.c2 = t2.d2);
```

### COUNT_TO_EXISTS

**Purpose:** The `COUNT_TO_EXISTS` hint enables query rewriting that converts `COUNT` subqueries into `EXISTS` subqueries. Its reverse operation is the `NO_COUNT_TO_EXISTS` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `COUNT_TO_EXISTS` hint enables query rewriting that converts `COUNT` subqueries into `EXISTS` subqueries. Its reverse operation is the `NO_COUNT_TO_EXISTS` hint.

**Syntax**


```sql
/*+ COUNT_TO_EXISTS [ ( [ @ qb_name ] [ qb_name_list ] ) ] */
```


**Parameters**


- `qb_name_list`: Optional. Specifies which query blocks to rewrite. If not specified, the hint applies to all subqueries.

**Examples**


In the following example, the `COUNT_TO_EXISTS` hint is used to enable query rewriting that converts `COUNT` subqueries into `EXISTS` subqueries.

```sql
-- The `COUNT_TO_EXISTS` hint directs the optimizer to convert the inner `COUNT` subquery into a more efficient `EXISTS` form.
SELECT /*+ COUNT_TO_EXISTS */ * FROM t1
WHERE (SELECT COUNT(*) FROM t2 WHERE t2.c1 = t1.c2) > 0;
```

### ELIMINATE_JOIN

**Purpose:** The `ELIMINATE_JOIN` hint controls query rewriting that eliminates joins. Its reverse operation is the `NO_ELIMINATE_JOIN` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `ELIMINATE_JOIN` hint controls query rewriting that eliminates joins. Its reverse operation is the `NO_ELIMINATE_JOIN` hint.

**Syntax**


```sql
/*+ ELIMINATE_JOIN [ ( [ @ qb_name ] [ table_list ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.
- `table_list`: Optional. Specifies which join tables to eliminate. If not specified, the hint applies to all join tables.

**Examples**


In the following example, the `ELIMINATE_JOIN` hint is used to enable query rewriting that eliminates joins.

```sql
-- The `ELIMINATE_JOIN` hint is used to find and eliminate the self-join on t1.
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);
SELECT /*+ ELIMINATE_JOIN */ *
FROM t1 a, t1 b
WHERE a.c1 = b.c1;
```

### FAST_MINMAX

**Purpose:** The `FAST_MINMAX` hint enables query rewriting for queries using the `MIN` and `MAX` aggregate functions. It instructs the query optimizer to rewrite the query for faster retrieval of minimum and maximum values. The reverse operation is the `NO_FAST_MINMAX` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `FAST_MINMAX` hint enables query rewriting for queries using the `MIN` and `MAX` aggregate functions. It instructs the query optimizer to rewrite the query for faster retrieval of minimum and maximum values. The reverse operation is the `NO_FAST_MINMAX` hint.

**Syntax**


```sql
/*+ FAST_MINMAX [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint to.

**Examples**


The following example shows how to use the `FAST_MINMAX` hint to enable query rewriting for `MIN` and `MAX` optimization.

```sql
CREATE TABLE t1(c1 int primary key, c2 int, c3 int);
-- Use the `FAST_MINMAX` hint to calculate MAX(c1) as quickly as possible.
SELECT /*+ FAST_MINMAX */ MAX(c1) FROM t1;
```

### INLINE

**Purpose:** The `INLINE` hint specifies to expand a common table expression (CTE) and integrate it directly into the main query. The reverse operation is the `MATERIALIZE` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `INLINE` hint specifies to expand a common table expression (CTE) and integrate it directly into the main query. The reverse operation is the `MATERIALIZE` hint.

**Syntax**


```sql
/*+ INLINE [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint to.

**Examples**


The following example shows how to use the `INLINE` hint to expand the CTE defined in `with cte`.

```sql
-- Use the `INLINE` hint to directly use the subquery content defined in with cte in the main query.
WITH cte AS (
  SELECT /*+INLINE*/ t1.*
  FROM t1
  JOIN t2 ON t1.c1 = t2.c1
)
SELECT * FROM cte A, cte B;
```

### JOIN_FIRST_UNNEST

**Purpose:** The `JOIN_FIRST_UNNEST` hint enables query rewriting for aggregate subquery lifting by prioritizing the use of join operations to optimize subqueries containing aggregate functions. The reverse operation is the `NO_JOIN_FIRST_UNNEST` hint. Note: It is not recommended to directly use the `JOIN_FIRST_UNNEST` or `NO_JOIN_FIRST_UNNEST` hints. Instead, use the `UNNEST` or `NO_UNNEST` hints to influence subquery lifting.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `JOIN_FIRST_UNNEST` hint enables query rewriting for aggregate subquery lifting by prioritizing the use of join operations to optimize subqueries containing aggregate functions. The reverse operation is the `NO_JOIN_FIRST_UNNEST` hint.

Note: It is not recommended to directly use the `JOIN_FIRST_UNNEST` or `NO_JOIN_FIRST_UNNEST` hints. Instead, use the `UNNEST` or `NO_UNNEST` hints to influence subquery lifting.

**Syntax**


```sql
/*+ JOIN_FIRST_UNNEST [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint to.

**Examples**


The following example shows how to use the `JOIN_FIRST_UNNEST` hint to enable query rewriting for aggregate subqueries by prioritizing join operations.

```sql
-- Use the `JOIN_FIRST_UNNEST` hint to prioritize join operations in the execution plan when handling subqueries containing aggregate functions (such as AVG).
SELECT * FROM t1
WHERE t1.c1 > (
  SELECT /*+ JOIN_FIRST_UNNEST */ AVG(d1)
  FROM t2
  WHERE t1.c2 = t2.d2
);
```

### LEFT_TO_ANTI

**Purpose:** The `LEFT_TO_ANTI` hint enables the query rewrite that converts `OUTER JOIN` to `ANTI JOIN`. Its reverse operation is the `NO_LEFT_TO_ANTI` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `LEFT_TO_ANTI` hint enables the query rewrite that converts `OUTER JOIN` to `ANTI JOIN`. Its reverse operation is the `NO_LEFT_TO_ANTI` hint.

**Syntax**


```sql
/*+ LEFT_TO_ANTI [ ( [ @ qb_name ] [ table_list ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.
- `table_list`: Optional. Specifies the right table of a specific `LEFT JOIN` to which this hint applies. If this parameter is omitted, this hint applies to all `OUTER JOIN` operations.

**Examples**


The following query example uses the `LEFT_TO_ANTI` hint to enable the query rewrite that converts `OUTER JOIN` to `ANTI JOIN`.

```sql
CREATE TABLE t1(c1 int primary key, c2 int, c3 int);
CREATE TABLE t2(c1 int primary key, c2 int, c3 int);

SELECT /*+ LEFT_TO_ANTI(t2) */ * FROM t1 LEFT JOIN t2 ON t1.c2 = t2.c2 WHERE t2.c1 IS NULL;
```

### MATERIALIZE

**Purpose:** The `MATERIALIZE` hint controls whether to materialize or not to expand a common table expression (CTE). The reverse operation is the `INLINE` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `MATERIALIZE` hint controls whether to materialize or not to expand a common table expression (CTE). The reverse operation is the `INLINE` hint.

**Syntax**


```sql
/*+ MATERIALIZE [ ( [ @ qb_name ] [ qb_name_list ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint to.
- `qb_name_list`: Optional. Specifies the query blocks to prevent from being materialized. If not specified, no CTE is materialized. It is recommended to use the `MATERIALIZE` hint only within CTEs defined in `with cte`.

**Examples**


The following examples show how to use the `MATERIALIZE` hint to prevent the expansion of CTEs defined in `with cte` or to actively materialize CTEs for query blocks in the query.

```sql
-- Example 1: Materialize a single CTE
WITH cte AS (
  SELECT /*+MATERIALIZE*/ * FROM t1
)
SELECT * FROM cte;

-- Example 2: Materialize multiple query blocks
SELECT /*+MATERIALIZE(("SEL$2", "SEL$3"))*/ v1.*
FROM   (SELECT t1.* FROM t1 JOIN t2 ON t1.c1 = t2.c1) v1,
       (SELECT t1.* FROM t1 JOIN t2 ON t1.c1 = t2.c1) v2,
       (SELECT t1.* FROM t1 JOIN t2 ON t1.c1 = t2.c1) v3,
       (SELECT t1.* FROM t1 JOIN t2 ON t1.c1 = t2.c1) v4;
```

### NO_AGGR_FIRST_UNNEST

**Purpose:** The `NO_AGGR_FIRST_UNNEST` hint prevents the optimizer from prioritizing independent aggregation calculations when handling subqueries with aggregate functions. Its reverse operation is the `AGGR_FIRST_UNNEST` hint. It is not recommended to directly use the `AGGR_FIRST_UNNEST` or `NO_AGGR_FIRST_UNNEST` hints because they directly affect the rewriting behavior of subquery lifting. Generally, if you need more basic control over subquery lifting behavior, it is recommended to use the `UNNEST` or `NO_UNNEST` hints instead.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_AGGR_FIRST_UNNEST` hint prevents the optimizer from prioritizing independent aggregation calculations when handling subqueries with aggregate functions. Its reverse operation is the `AGGR_FIRST_UNNEST` hint.

It is not recommended to directly use the `AGGR_FIRST_UNNEST` or `NO_AGGR_FIRST_UNNEST` hints because they directly affect the rewriting behavior of subquery lifting. Generally, if you need more basic control over subquery lifting behavior, it is recommended to use the `UNNEST` or `NO_UNNEST` hints instead.

**Syntax**


```sql
/*+ NO_AGGR_FIRST_UNNEST [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


In the following example, the `NO_AGGR_FIRST_UNNEST` hint is used, keeping the original form of the subquery without prioritizing aggregation during query rewriting.

```sql
SELECT * FROM t1
WHERE t1.c1 > (SELECT /*+ NO_AGGR_FIRST_UNNEST */ AVG(d1)
               FROM t2
               WHERE t1.c2 = t2.d2);
```

### NO_COUNT_TO_EXISTS

**Purpose:** The `NO_COUNT_TO_EXISTS` hint disables query rewriting that converts `COUNT` subqueries into `EXISTS` subqueries. Its reverse operation is the `COUNT_TO_EXISTS` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_COUNT_TO_EXISTS` hint disables query rewriting that converts `COUNT` subqueries into `EXISTS` subqueries. Its reverse operation is the `COUNT_TO_EXISTS` hint.

**Syntax**


```sql
/*+ NO_COUNT_TO_EXISTS [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.
- `qb_name_list`: Optional. Specifies which query blocks to exclude from rewriting. If not specified, the hint applies to all subqueries.

**Examples**


In the following example, the `NO_COUNT_TO_EXISTS` hint is used to disable query rewriting that converts `COUNT` subqueries into `EXISTS` subqueries.

```sql
-- The `NO_COUNT_TO_EXISTS` hint keeps the original `COUNT` subquery unchanged.
SELECT /*+ NO_COUNT_TO_EXISTS */ * FROM t1
WHERE (SELECT COUNT(*) FROM t2 WHERE t2.c1 = t1.c2) > 0;
```

### NO_ELIMINATE_JOIN

**Purpose:** The `NO_ELIMINATE_JOIN` hint disables query rewriting that eliminates joins, retaining all specified joins. Its reverse operation is the `ELIMINATE_JOIN` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_ELIMINATE_JOIN` hint disables query rewriting that eliminates joins, retaining all specified joins. Its reverse operation is the `ELIMINATE_JOIN` hint.

**Syntax**


```sql
/*+ NO_ELIMINATE_JOIN [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.
- `table_list`: Optional. Specifies which join tables to exclude from elimination. If not specified, the hint applies to all join tables.

**Examples**


In the following example, the `NO_ELIMINATE_JOIN` hint is used to disable query rewriting that eliminates joins.

```sql
-- The `NO_ELIMINATE_JOIN` hint ensures that the join operation is retained.
SELECT /*+ NO_ELIMINATE_JOIN */ *
FROM t1 a, t1 b
WHERE a.c1 = b.c1;
```

### NO_FAST_MINMAX

**Purpose:** The `NO_FAST_MINMAX` hint disables query rewriting for queries using the `MIN` and `MAX` aggregate functions. The reverse operation is the `FAST_MINMAX` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_FAST_MINMAX` hint disables query rewriting for queries using the `MIN` and `MAX` aggregate functions. The reverse operation is the `FAST_MINMAX` hint.

**Syntax**


```sql
/*+ NO_FAST_MINMAX [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint to.

**Examples**


The following example shows how to use the `NO_FAST_MINMAX` hint to disable query rewriting for `MIN` and `MAX` optimization.

```sql
CREATE TABLE t1(c1 int primary key, c2 int, c3 int);
-- Use the `NO_FAST_MINMAX` hint to prevent the optimizer from accelerating the MAX(c1) operation.
SELECT /*+ NO_FAST_MINMAX */ MAX(c1) FROM t1;
```

### NO_JOIN_FIRST_UNNEST

**Purpose:** The `NO_JOIN_FIRST_UNNEST` hint disables query rewriting for aggregate subquery lifting by preventing the prioritization of join operations. Using this hint, the query optimizer will not consider join-based strategies. The reverse operation is the `JOIN_FIRST_UNNEST` hint. Note: It is not recommended to directly use the `JOIN_FIRST_UNNEST` or `NO_JOIN_FIRST_UNNEST` hints. Instead, use the `UNNEST` or `NO_UNNEST` hints to influence subquery lifting.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_JOIN_FIRST_UNNEST` hint disables query rewriting for aggregate subquery lifting by preventing the prioritization of join operations. Using this hint, the query optimizer will not consider join-based strategies. The reverse operation is the `JOIN_FIRST_UNNEST` hint.

Note: It is not recommended to directly use the `JOIN_FIRST_UNNEST` or `NO_JOIN_FIRST_UNNEST` hints. Instead, use the `UNNEST` or `NO_UNNEST` hints to influence subquery lifting.

**Syntax**


```sql
/*+ NO_JOIN_FIRST_UNNEST [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint to.

**Examples**


The following example shows how to use the `NO_JOIN_FIRST_UNNEST` hint to disable query rewriting for aggregate subqueries by preventing the prioritization of join operations.

```sql
-- Use the `NO_JOIN_FIRST_UNNEST` hint to prevent the optimizer from prioritizing join operations when handling subqueries.
SELECT * FROM t1
WHERE t1.c1 > (
  SELECT /*+ NO_JOIN_FIRST_UNNEST */ AVG(d1)
  FROM t2
  WHERE t1.c2 = t2.d2
);
```

### NO_LEFT_TO_ANTI

**Purpose:** The `NO_LEFT_TO_ANTI` hint disables the query rewrite that converts `OUTER JOIN` to `ANTI JOIN`. Its reverse operation is the `LEFT_TO_ANTI` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_LEFT_TO_ANTI` hint disables the query rewrite that converts `OUTER JOIN` to `ANTI JOIN`. Its reverse operation is the `LEFT_TO_ANTI` hint.

**Syntax**


```sql
/*+ NO_LEFT_TO_ANTI [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `NO_LEFT_TO_ANTI` hint to disable the query rewrite that converts `OUTER JOIN` to `ANTI JOIN`.

```sql
CREATE TABLE t1(c1 int primary key, c2 int, c3 int);
CREATE TABLE t2(c1 int primary key, c2 int, c3 int);

SELECT /*+ NO_LEFT_TO_ANTI */ * FROM t1
LEFT JOIN t2 ON t1.c2 = t2.c2
WHERE t2.c1 IS NULL;
```

### NO_OUTER_TO_INNER

**Purpose:** The `NO_OUTER_TO_INNER` hint disables the query rewrite that converts `OUTER JOIN` to `INNER JOIN`. Its reverse operation is the `OUTER_TO_INNER` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_OUTER_TO_INNER` hint disables the query rewrite that converts `OUTER JOIN` to `INNER JOIN`. Its reverse operation is the `OUTER_TO_INNER` hint.

**Syntax**


```sql
/*+ NO_OUTER_TO_INNER [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `NO_OUTER_TO_INNER` hint to disable the query rewrite that converts `OUTER JOIN` to `INNER JOIN`.

```sql
-- The WHERE condition b.c1 > 0 applies only to table b and implicitly excludes the possibility of null values in the right table of the outer join, making the outer join operation behave like an inner join.
SELECT /*+ NO_OUTER_TO_INNER */ *
FROM t1 a
LEFT JOIN t1 b ON a.c2 = b.c2
WHERE b.c1 > 0;
```

### NO_PRED_DEDUCE

**Purpose:** The `NO_PRED_DEDUCE` hint disables the query rewrite that derives new predicates from existing ones and pushes them down. Its reverse operation is the `PRED_DEDUCE` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_PRED_DEDUCE` hint disables the query rewrite that derives new predicates from existing ones and pushes them down. Its reverse operation is the `PRED_DEDUCE` hint.

**Syntax**


```sql
/*+ NO_PRED_DEDUCE [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `NO_PRED_DEDUCE` hint to disable the query rewrite that derives new predicates from existing ones and pushes them down.

```sql
-- Disable predicate deduction to rewrite the outer query.
select /*+no_pred_deduce*/ c1
from (
  -- Disable subquery merging to ensure the no_merge hint is effective.
  select /*+no_merge*/ t1.* from t1
)
where c1 = 3;
```

### NO_PROJECT_PRUNE

**Purpose:** The `NO_PROJECT_PRUNE` hint disables the query rewrite operation of project pruning. Project pruning automatically trims unused output columns during query optimization. When it is necessary to retain these columns for specific performance or functional requirements, the `NO_PROJECT_PRUNE` hint becomes particularly important. Its reverse operation is the `PROJECT_PRUNE` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_PROJECT_PRUNE` hint disables the query rewrite operation of project pruning. Project pruning automatically trims unused output columns during query optimization. When it is necessary to retain these columns for specific performance or functional requirements, the `NO_PROJECT_PRUNE` hint becomes particularly important. Its reverse operation is the `PROJECT_PRUNE` hint.

**Syntax**


```sql
/*+ NO_PROJECT_PRUNE [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies which query block should avoid applying project pruning. This provides more precise control when multiple query blocks exist.

**Examples**


In the following query example, the `NO_PROJECT_PRUNE` hint is used to disable project pruning rewrite. This setting ensures that even if all output columns except `c1` are not needed, these columns will still remain in the result of the inline view.

```sql
select c1 from (select /*+no_merge no_project_prune*/ t1.* from t1);
```

### NO_PULLUP_EXPR

**Purpose:** The `NO_PULLUP_EXPR` hint disables the optimizer from performing expression pulling up optimization. Its reverse operation is the `PULLUP_EXPR` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_PULLUP_EXPR` hint disables the optimizer from performing expression pulling up optimization. Its reverse operation is the `PULLUP_EXPR` hint.

**Syntax**


```sql
/*+ NO_PULLUP_EXPR [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint.

**Examples**


In the following query example, the `NO_PULLUP_EXPR` hint is used to disable expression pulling up rewrite. After the expression pulling up query rewrite is triggered, the subquery in the `SELECT` clause of the inline view is prevented from being pulled up to the outer level.

```sql
-- Assume that t1 is an existing table
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- Execute a query with the NO_PULLUP_EXPR hint
SELECT *
FROM (SELECT /*+no_merge no_pullup_expr*/ t1.*,
             (SELECT c2 FROM t1 WHERE c1 = 1)
      FROM t1)
WHERE c1 > 1000;
```

### NO_PUSH_LIMIT

**Purpose:** The `NO_PUSH_LIMIT` hint prevents the optimizer from altering the original query structure, especially when limit pushing down to the inner part of a join query is not desired. Its reverse operation is the `PUSH_LIMIT` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_PUSH_LIMIT` hint prevents the optimizer from altering the original query structure, especially when limit pushing down to the inner part of a join query is not desired. Its reverse operation is the `PUSH_LIMIT` hint.

**Syntax**


```sql
/*+ NO_PUSH_LIMIT [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint.

**Examples**


In the following query example, the `NO_PUSH_LIMIT` hint is used to disable limit pushing down join rewrite.

```sql
-- Assume that t1 is an existing table
CREATE TABLE t1(c1 int primary key, c2 int, c3 int);

-- Query example using the NO_PUSH_LIMIT hint
SELECT /*+no_push_limit*/ *
FROM t1 a LEFT JOIN t1 b ON a.c2 = b.c2
FETCH NEXT 10 ROWS ONLY;
```

### NO_REPLACE_CONST

**Purpose:** The `NO_REPLACE_CONST` hint disables constant propagation query rewrite to prevent unnecessary rewriting in certain scenarios. Its reverse operation is the `REPLACE_CONST` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_REPLACE_CONST` hint disables constant propagation query rewrite to prevent unnecessary rewriting in certain scenarios. Its reverse operation is the `REPLACE_CONST` hint.

**Syntax**


```sql
/*+ NO_REPLACE_CONST [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint.

**Examples**


In the following query example, the `NO_REPLACE_CONST` hint is used to disable constant propagation query rewrite.

```sql
-- Assume that t1 is an existing table
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- Query using the NO_REPLACE_CONST hint to maintain the original query conditions
SELECT /*+no_replace_const*/ c2
FROM t1
WHERE c1 = c2 AND c2 = 4;
```

### NO_SIMPLIFY_DISTINCT

**Purpose:** The `NO_SIMPLIFY_DISTINCT` hint explicitly disables the optimizer from simplifying queries with DISTINCT operations. This can be useful in specific scenarios where you want to maintain the original query structure and prevent the optimizer from making unwanted rewrites. Its reverse operation is the `SIMPLIFY_DISTINCT` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_SIMPLIFY_DISTINCT` hint explicitly disables the optimizer from simplifying queries with DISTINCT operations. This can be useful in specific scenarios where you want to maintain the original query structure and prevent the optimizer from making unwanted rewrites. Its reverse operation is the `SIMPLIFY_DISTINCT` hint.

**Syntax**


```sql
/*+ NO_SIMPLIFY_DISTINCT [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example shows how to use the `NO_SIMPLIFY_DISTINCT` hint to disable a series of query rewrites related to DISTINCT operations.

```sql
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

SELECT DISTINCT c1, c2
FROM (SELECT /*+no_simplify_distinct*/ DISTINCT t1.* FROM t1);
```

### NO_SIMPLIFY_EXPR

**Purpose:** The `NO_SIMPLIFY_EXPR` hint disables the optimizer from rewriting and simplifying expressions in queries. Its reverse operation is the `SIMPLIFY_EXPR` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_SIMPLIFY_EXPR` hint disables the optimizer from rewriting and simplifying expressions in queries. Its reverse operation is the `SIMPLIFY_EXPR` hint.

**Syntax**


```sql
/*+ NO_SIMPLIFY_EXPR [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example shows how to use the `NO_SIMPLIFY_EXPR` hint to disable the optimizer from rewriting and simplifying expressions in queries.

```sql
-- Use the `NO_SIMPLIFY_EXPR` hint to prevent expression rewriting and simplification.
SELECT /*+no_simplify_expr*/ 1 FROM t1 WHERE c1 = 1 OR 1 = 1;
```

### NO_SIMPLIFY_GROUP_BY

**Purpose:** The `NO_SIMPLIFY_GROUP_BY` hint disables any query rewrites related to GROUP BY clauses to maintain the original query logic. Its reverse operation is the `SIMPLIFY_GROUP_BY` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_SIMPLIFY_GROUP_BY` hint disables any query rewrites related to GROUP BY clauses to maintain the original query logic. Its reverse operation is the `SIMPLIFY_GROUP_BY` hint.

**Syntax**


```sql
/*+ NO_SIMPLIFY_GROUP_BY [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example shows how to use the `NO_SIMPLIFY_GROUP_BY` hint to maintain the original GROUP BY logic and prevent any automated query optimizations.

```sql
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

SELECT /*+no_simplify_group_by*/ COUNT(DISTINCT c1) FROM t1 GROUP BY c2;
```

### NO_SIMPLIFY_LIMIT

**Purpose:** The `NO_SIMPLIFY_LIMIT` hint disables query rewrites related to LIMIT clauses. Its reverse operation is the `SIMPLIFY_LIMIT` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_SIMPLIFY_LIMIT` hint disables query rewrites related to LIMIT clauses. Its reverse operation is the `SIMPLIFY_LIMIT` hint.

**Syntax**


```sql
/*+ NO_SIMPLIFY_LIMIT [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example shows how to use the `NO_SIMPLIFY_LIMIT` hint to disable query rewrites related to LIMIT operations.

```sql
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- Use the `NO_SIMPLIFY_LIMIT` hint to ensure the original pagination logic remains unchanged.
SELECT /*+no_simplify_limit*/ *
FROM (SELECT /*+no_rewrite*/ ROWNUM cnt,
             (SELECT c2 FROM t1 WHERE c1 = 1)
      FROM t1)
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;
```

### NO_SIMPLIFY_ORDER_BY

**Purpose:** `NO_SIMPLIFY_ORDER_BY` Hint disables any query rewriting related to the `ORDER BY` clause to preserve the original logic of the query. Its reverse operation is the `SIMPLIFY_ORDER_BY` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

`NO_SIMPLIFY_ORDER_BY` Hint disables any query rewriting related to the `ORDER BY` clause to preserve the original logic of the query. Its reverse operation is the `SIMPLIFY_ORDER_BY` hint.

**Syntax**


```sql
/*+ NO_SIMPLIFY_ORDER_BY [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `NO_SIMPLIFY_ORDER_BY` hint to keep the original `ORDER BY` logic and prevent any automatic query optimization.

```sql
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

SELECT /*+no_simplify_order_by*/ c1 FROM
(SELECT /*+no_merge*/ * FROM t1 ORDER BY c2) ORDER BY c2 DESC;
```

### NO_SIMPLIFY_SET

**Purpose:** `NO_SIMPLIFY_SET` Hint disables query rewriting for set queries. Its reverse operation is the `SIMPLIFY_SET` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

`NO_SIMPLIFY_SET` Hint disables query rewriting for set queries. Its reverse operation is the `SIMPLIFY_SET` hint.

**Syntax**


```sql
/*+ NO_SIMPLIFY_SET [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.


**Note**
There is no direct way to add a hint to a set query's query block. Therefore, you must specify the query block to which the hint applies using the QB Name method.


**Examples**


The following query example uses the `NO_SIMPLIFY_SET` hint to disable query rewriting for set queries.

```sql
-- Assume that t1 is a pre-created table.
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- Use the NO_SIMPLIFY_SET hint to prevent set query rewriting.
SELECT /*+no_simplify_set(@set$1)*/ * FROM t1
UNION ALL
SELECT * FROM t1 WHERE 1 = 0;
```


In the example above, a hint (`/*+no_simplify_set(@set$1)*/`) is included. This hint disables the database optimizer from automatically simplifying the specific set operation (`UNION ALL`) query. `@set$1` is a Query Block Name (QB Name), which in this case is used to identify the entire `UNION ALL` query statement.

### NO_SIMPLIFY_SUBQUERY

**Purpose:** `NO_SIMPLIFY_SUBQUERY` Hint prevents the optimizer from automatically rewriting subqueries, preserving the original query structure and logic. Its reverse operation is the `SIMPLIFY_SUBQUERY` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

`NO_SIMPLIFY_SUBQUERY` Hint prevents the optimizer from automatically rewriting subqueries, preserving the original query structure and logic. Its reverse operation is the `SIMPLIFY_SUBQUERY` hint.

**Syntax**


```sql
/*+ NO_SIMPLIFY_SUBQUERY [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `NO_SIMPLIFY_SUBQUERY` hint to disable query rewriting for subqueries.

```sql
-- Assume that t1 is a pre-created table.
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- The query example demonstrates the use of the `NO_SIMPLIFY_SUBQUERY` hint to ensure that the subquery remains unchanged and is not rewritten by the optimizer.
SELECT /*+no_simplify_subquery*/ * FROM t1
WHERE EXISTS (SELECT * FROM t1);
```

### NO_SIMPLIFY_WINFUNC

**Purpose:** The `NO_SIMPLIFY_WINFUNC` hint prevents the optimizer from rewriting queries containing window functions, ensuring that special logic remains unchanged. Its reverse operation is the `SIMPLIFY_WINFUNC` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_SIMPLIFY_WINFUNC` hint prevents the optimizer from rewriting queries containing window functions, ensuring that special logic remains unchanged. Its reverse operation is the `SIMPLIFY_WINFUNC` hint.

**Syntax**


```sql
/*+ NO_SIMPLIFY_WINFUNC [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `NO_SIMPLIFY_WINFUNC` hint to disable query rewriting for window function-related queries.

```sql
-- Assuming that the t1 table has been created
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- The query with the NO_SIMPLIFY_WINFUNC hint maintains the original behavior of the window function.
SELECT /*+no_simplify_winfunc*/ MAX(c2) OVER (PARTITION BY c1) FROM t1;
```

### NO_UNNEST

**Purpose:** The `NO_UNNEST` hint prevents query rewriting by unnesting subqueries into joins, even when a subquery can be effectively rewritten into a join. Its reverse operation is the `UNNEST` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `NO_UNNEST` hint prevents query rewriting by unnesting subqueries into joins, even when a subquery can be effectively rewritten into a join. Its reverse operation is the `UNNEST` hint.

**Syntax**


```sql
/*+ NO_UNNEST [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `NO_UNNEST` hint to disable query rewriting for subquery unnesting.

```sql
-- Assuming that the t1 table has been created
CREATE TABLE t1(c1 INT, c2 INT, c3 INT);

-- The query with the NO_UNNEST hint prevents the subquery from being automatically rewritten into a join operation.
SELECT (SELECT /*+no_unnest*/ COUNT(*)
        FROM t1 b
        WHERE a.c2 = b.c2)
FROM t1 a;
```

### OUTER_TO_INNER

**Purpose:** The `OUTER_TO_INNER` hint enables the query rewrite that converts `OUTER JOIN` to `INNER JOIN`. Its reverse operation is the `NO_OUTER_TO_INNER` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `OUTER_TO_INNER` hint enables the query rewrite that converts `OUTER JOIN` to `INNER JOIN`. Its reverse operation is the `NO_OUTER_TO_INNER` hint.

**Syntax**


```sql
/*+ OUTER_TO_INNER [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `OUTER_TO_INNER` hint to enable the query rewrite that converts `OUTER JOIN` to `INNER JOIN`.

```sql
-- The WHERE condition b.c1 > 0 applies only to table b and implicitly excludes the possibility of null values in the right table of the outer join, making the outer join operation behave like an inner join.
SELECT /*+ OUTER_TO_INNER */ *
FROM t1 a
LEFT JOIN t1 b ON a.c2 = b.c2
WHERE b.c1 > 0;
```

### PRED_DEDUCE

**Purpose:** The `PRED_DEDUCE` hint enables the query rewrite that derives new predicates from existing ones and pushes them down. This rewrite is effective for nested queries and joins. Its reverse operation is the `NO_PRED_DEDUCE` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `PRED_DEDUCE` hint enables the query rewrite that derives new predicates from existing ones and pushes them down. This rewrite is effective for nested queries and joins. Its reverse operation is the `NO_PRED_DEDUCE` hint.

**Syntax**


```sql
/*+ PRED_DEDUCE [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `PRED_DEDUCE` hint to enable the query rewrite that derives new predicates from existing ones and pushes them down.

```sql
-- Enable predicate deduction to rewrite the outer query.
select /*+pred_deduce*/ c1
from (
  -- Disable subquery merging to ensure the no_merge hint is effective.
  select /*+no_merge*/ t1.* from t1
)
where c1 = 3;
```

### PROJECT_PRUNE

**Purpose:** The `PROJECT_PRUNE` hint optimizes query execution by reducing the amount of data processed, especially in large datasets and complex queries. It prunes unnecessary columns to reduce the output of query blocks. This query rewrite technique, known as Project Pruning, improves query efficiency, particularly when processing inner query blocks. Its reverse operation is the `NO_PROJECT_PRUNE` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `PROJECT_PRUNE` hint optimizes query execution by reducing the amount of data processed, especially in large datasets and complex queries. It prunes unnecessary columns to reduce the output of query blocks. This query rewrite technique, known as Project Pruning, improves query efficiency, particularly when processing inner query blocks. Its reverse operation is the `NO_PROJECT_PRUNE` hint.

**Syntax**


```sql
/*+ PROJECT_PRUNE [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the particular query block to which the `PROJECT_PRUNE` hint applies, providing finer-grained control for query optimization.

**Examples**


The following query example uses the `PROJECT_PRUNE` hint to enable the Project Pruning rewrite mechanism. This causes the optimizer to prune all output columns of the inline view except for the C1 column.

```sql
select c1 from (select /*+no_merge project_prune*/ t1.* from t1);
```

### PULLUP_EXPR

**Purpose:** The `PULLUP_EXPR` hint enables the optimizer to pull up (promote) subquery expressions to the parent query level. Its reverse operation is the `NO_PULLUP_EXPR` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `PULLUP_EXPR` hint enables the optimizer to pull up (promote) subquery expressions to the parent query level. Its reverse operation is the `NO_PULLUP_EXPR` hint.

**Syntax**


```sql
/*+ PULLUP_EXPR [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint.

**Examples**


In the following query example, the `PULLUP_EXPR` hint is used to enable expression pulling up rewrite. After the expression pulling up query rewrite is triggered, the subquery in the `SELECT` clause of the inline view is pulled up to the outer level.

```sql
-- Assume that t1 is an existing table
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- Execute a query with the PULLUP_EXPR hint
SELECT *
FROM (SELECT /*+no_merge pullup_expr*/ t1.*,
             (SELECT c2 FROM t1 WHERE c1 = 1)
      FROM t1)
WHERE c1 > 1000;
```

### PUSH_LIMIT

**Purpose:** The `PUSH_LIMIT` hint allows the optimizer to push down (lower) the LIMIT clause (which restricts the number of returned rows) into the inner part of a join query, such as an outer join or a Cartesian product, significantly improving the efficiency of paginated queries. Its reverse operation is the `NO_PUSH_LIMIT` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `PUSH_LIMIT` hint allows the optimizer to push down (lower) the LIMIT clause (which restricts the number of returned rows) into the inner part of a join query, such as an outer join or a Cartesian product, significantly improving the efficiency of paginated queries. Its reverse operation is the `NO_PUSH_LIMIT` hint.

**Syntax**


```sql
/*+ PUSH_LIMIT [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint.

**Examples**


In the following query example, the `PUSH_LIMIT` hint is used to enable limit pushing down join rewrite.

```sql
-- Assume that t1 is an existing table
CREATE TABLE t1(c1 int primary key, c2 int, c3 int);

-- Query example using the PUSH_LIMIT hint
SELECT /*+push_limit*/ *
FROM t1 a LEFT JOIN t1 b on a.c2 = b.c2
fetch next 10 rows only;
```

### REPLACE_CONST

**Purpose:** The `REPLACE_CONST` hint enables the optimizer to perform constant propagation query rewrite, which involves replacing equality conditions in the query with constants to reduce complexity and improve query efficiency. Its reverse operation is the `NO_REPLACE_CONST` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `REPLACE_CONST` hint enables the optimizer to perform constant propagation query rewrite, which involves replacing equality conditions in the query with constants to reduce complexity and improve query efficiency. Its reverse operation is the `NO_REPLACE_CONST` hint.

**Syntax**


```sql
/*+ REPLACE_CONST [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to apply the hint.

**Examples**


In the following query example, the `REPLACE_CONST` hint is used to enable constant propagation query rewrite.

```sql
-- Assume that t1 is an existing table
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- Query using the REPLACE_CONST hint to simplify the WHERE clause
SELECT /*+replace_const*/ c2
FROM t1
WHERE c1 = c2 AND c2 = 4;
```

### SIMPLIFY_DISTINCT

**Purpose:** The `SIMPLIFY_DISTINCT` hint enables the optimizer to rewrite and optimize queries with DISTINCT operations. Its reverse operation is the `NO_SIMPLIFY_DISTINCT` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `SIMPLIFY_DISTINCT` hint enables the optimizer to rewrite and optimize queries with DISTINCT operations. Its reverse operation is the `NO_SIMPLIFY_DISTINCT` hint.

**Syntax**


```sql
/*+ SIMPLIFY_DISTINCT [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example shows how to use the `SIMPLIFY_DISTINCT` hint to enable a series of query rewrites related to DISTINCT operations.

```sql
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

SELECT DISTINCT c1, c2
FROM (SELECT /*+simplify_distinct*/ DISTINCT t1.* FROM t1);
```

### SIMPLIFY_EXPR

**Purpose:** The `SIMPLIFY_EXPR` hint enables the optimizer to rewrite and simplify expressions in queries. Its reverse operation is the `NO_SIMPLIFY_EXPR` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `SIMPLIFY_EXPR` hint enables the optimizer to rewrite and simplify expressions in queries. Its reverse operation is the `NO_SIMPLIFY_EXPR` hint.

**Syntax**


```sql
/*+ SIMPLIFY_EXPR [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example shows how to use the `SIMPLIFY_EXPR` hint to enable the optimizer to rewrite and simplify expressions in queries.

```sql
-- Use the `SIMPLIFY_EXPR` hint to optimize query efficiency by removing redundant logic during condition simplification.
SELECT /*+simplify_expr*/ 1 FROM t1 WHERE c1 = 1 OR 1 = 1;
```

### SIMPLIFY_GROUP_BY

**Purpose:** The `SIMPLIFY_GROUP_BY` hint enables the optimizer to rewrite and simplify queries with GROUP BY clauses. Its reverse operation is the `NO_SIMPLIFY_GROUP_BY` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `SIMPLIFY_GROUP_BY` hint enables the optimizer to rewrite and simplify queries with GROUP BY clauses. Its reverse operation is the `NO_SIMPLIFY_GROUP_BY` hint.

**Syntax**


```sql
/*+ SIMPLIFY_GROUP_BY [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example shows how to use the `SIMPLIFY_GROUP_BY` hint to enable query rewrites related to GROUP BY operations.

```sql
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);
-- Use the `SIMPLIFY_GROUP_BY` hint to enable the optimizer to rewrite and simplify GROUP BY operations.
SELECT /*+simplify_group_by*/ COUNT(DISTINCT c1) FROM t1 GROUP BY c2;
```

### SIMPLIFY_LIMIT

**Purpose:** The `SIMPLIFY_LIMIT` hint enables the optimizer to rewrite and simplify queries with LIMIT clauses to improve the performance of pagination queries. Its reverse operation is the `NO_SIMPLIFY_LIMIT` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `SIMPLIFY_LIMIT` hint enables the optimizer to rewrite and simplify queries with LIMIT clauses to improve the performance of pagination queries. Its reverse operation is the `NO_SIMPLIFY_LIMIT` hint.

**Syntax**


```sql
/*+ SIMPLIFY_LIMIT [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which the hint applies.

**Examples**


The following query example shows how to use the `SIMPLIFY_LIMIT` hint to enable query rewrites related to LIMIT operations.

```sql
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- Use the `SIMPLIFY_LIMIT` hint instead of the `NO_SIMPLIFY_LIMIT` hint to correct the usage in the example.
SELECT /*+simplify_limit*/ *
FROM (SELECT /*+no_rewrite*/ ROWNUM cnt,
             (SELECT c2 FROM t1 WHERE c1 = 1)
      FROM t1)
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;
```

### SIMPLIFY_ORDER_BY

**Purpose:** `SIMPLIFY_ORDER_BY` Hint is used to optimize queries that contain the `ORDER BY` clause. This hint enables the query optimizer to simplify and rewrite the `ORDER BY` operations. Its reverse operation is the `NO_SIMPLIFY_ORDER_BY` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

`SIMPLIFY_ORDER_BY` Hint is used to optimize queries that contain the `ORDER BY` clause. This hint enables the query optimizer to simplify and rewrite the `ORDER BY` operations. Its reverse operation is the `NO_SIMPLIFY_ORDER_BY` hint.

**Syntax**


```sql
/*+ SIMPLIFY_ORDER_BY [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `SIMPLIFY_ORDER_BY` hint to enable query rewriting for the `ORDER BY` clause.

```sql
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);
-- The `SIMPLIFY_ORDER_BY` hint enables the optimizer to rewrite the query to optimize the execution of the ORDER BY operation.
SELECT /*+simplify_order_by*/ c1 FROM
(SELECT /*+no_merge*/ * FROM t1 ORDER BY c2) ORDER BY c2 DESC;
```

### SIMPLIFY_SET

**Purpose:** `SIMPLIFY_SET` Hint enables the optimizer to rewrite set operations such as `UNION`, `INTERSECT`, and `EXCEPT`. Its reverse operation is the `NO_SIMPLIFY_SET` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

`SIMPLIFY_SET` Hint enables the optimizer to rewrite set operations such as `UNION`, `INTERSECT`, and `EXCEPT`. Its reverse operation is the `NO_SIMPLIFY_SET` hint.

**Syntax**


```sql
/*+ SIMPLIFY_SET [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.


**Note**
There is no direct way to add a hint to a set query's query block. Therefore, you must specify the query block to which the hint applies using the QB Name method.


**Examples**


The following query example uses the `SIMPLIFY_SET` hint to enable query rewriting for set queries.

```sql
-- Assume that t1 is a pre-created table.
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- Use the SIMPLIFY_SET hint to optimize the query.
SELECT /*+simplify_set(@set$1)*/ * FROM t1
UNION ALL
SELECT * FROM t1 WHERE 1 = 0;
```


In the example above, a hint (`/*+simplify_set(@set$1)*/`) is included. This hint disables the database optimizer from automatically simplifying the specific set operation (`UNION ALL`) query. `@set$1` is a Query Block Name (QB Name), which in this case is used to identify the entire `UNION ALL` query statement.

### SIMPLIFY_SUBQUERY

**Purpose:** `SIMPLIFY_SUBQUERY` Hint enables the optimizer to rewrite nested subqueries, which helps to convert or eliminate unnecessary subquery structures to simplify the query logic. Its reverse operation is the `NO_SIMPLIFY_SUBQUERY` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

`SIMPLIFY_SUBQUERY` Hint enables the optimizer to rewrite nested subqueries, which helps to convert or eliminate unnecessary subquery structures to simplify the query logic. Its reverse operation is the `NO_SIMPLIFY_SUBQUERY` hint.

**Syntax**


```sql
/*+ SIMPLIFY_SUBQUERY [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `SIMPLIFY_SUBQUERY` hint to enable query rewriting for subqueries.

```sql
-- Assume that t1 is a pre-created table.
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- The query example demonstrates the use of the `SIMPLIFY_SUBQUERY` hint to enable the optimizer to simplify or eliminate unnecessary subquery parts.
SELECT /*+simplify_subquery*/ * FROM t1
WHERE EXISTS (SELECT * FROM t1);
```

### SIMPLIFY_WINFUNC

**Purpose:** The `SIMPLIFY_WINFUNC` hint enables the optimizer to effectively rewrite queries containing window functions. Its reverse operation is the `NO_SIMPLIFY_WINFUNC` hint.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `SIMPLIFY_WINFUNC` hint enables the optimizer to effectively rewrite queries containing window functions. Its reverse operation is the `NO_SIMPLIFY_WINFUNC` hint.

**Syntax**


```sql
/*+ SIMPLIFY_WINFUNC [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `SIMPLIFY_WINFUNC` hint to enable query rewriting for window function-related queries.

```sql
-- Assuming that the t1 table has been created
CREATE TABLE t1(c1 INT PRIMARY KEY, c2 INT, c3 INT);

-- The query with the SIMPLIFY_WINFUNC hint enables the optimizer to identify and implement any possible rewriting to simplify the calculation of MAX(c2) OVER (PARTITION BY c1).
SELECT /*+simplify_winfunc*/ MAX(c2) OVER (PARTITION BY c1) FROM t1;
```

### UNNEST

**Purpose:** The `UNNEST` hint enables the optimizer to rewrite queries by unnesting subqueries into joins. It converts subqueries in the query into various joins. Its reverse operation is the `NO_UNNEST` hint. OceanBase Database supports further subquery unnesting optimizations, such as the `AGGR_FIRST_UNNEST` and `JOIN_FIRST_UNNEST` hints, which guide the optimizer to prioritize aggregation or join operations during subquery unnesting. However, in most scenarios, we recommend directly using the `UNNEST` hint, as it provides a general optimization strategy.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Heuristic transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/300.hints-related-to-heuristics-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Heuristic transformation

The `UNNEST` hint enables the optimizer to rewrite queries by unnesting subqueries into joins. It converts subqueries in the query into various joins. Its reverse operation is the `NO_UNNEST` hint.

OceanBase Database supports further subquery unnesting optimizations, such as the `AGGR_FIRST_UNNEST` and `JOIN_FIRST_UNNEST` hints, which guide the optimizer to prioritize aggregation or join operations during subquery unnesting. However, in most scenarios, we recommend directly using the `UNNEST` hint, as it provides a general optimization strategy.

**Syntax**


```sql
/*+ UNNEST [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the query block to which this hint applies.

**Examples**


The following query example uses the `UNNEST` hint to enable query rewriting for subquery unnesting.

```sql
-- Assuming that the t1 table has been created
CREATE TABLE t1(c1 INT, c2 INT, c3 INT);

-- The query with the UNNEST hint triggers subquery unnesting.
SELECT (SELECT /*+unnest*/ COUNT(*)
        FROM t1 b
        WHERE a.c2 = b.c2)
FROM t1 a;
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

## Query block > Join operations

### NO_PX_JOIN_FILTER

**Purpose:** The `NO_PX_JOIN_FILTER` hint instructs the optimizer to control the use of JOIN FILTER in HASH JOIN. The reverse operation of this hint is `PX_JOIN_FILTER`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

**Official example:** The cited hint documentation does not label an official example; none has been invented.

#### Documentation section 1: Query block > Join operations

The `NO_PX_JOIN_FILTER` hint instructs the optimizer to control the use of JOIN FILTER in HASH JOIN. The reverse operation of this hint is `PX_JOIN_FILTER`.

**Syntax**


```sql
/*+ NO_PX_JOIN_FILTER( table ) */
```

### NO_PX_PART_JOIN_FILTER

**Purpose:** The `NO_PX_PART_JOIN_FILTER` hint instructs the optimizer to manually disable PART FILTER. The reverse operation of this hint is `PX_PART_JOIN_FILTER`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

#### Documentation section 1: Query block > Join operations

The `NO_PX_PART_JOIN_FILTER` hint instructs the optimizer to manually disable PART FILTER. The reverse operation of this hint is `PX_PART_JOIN_FILTER`.

**Syntax**


```sql
/*+ NO_PX_PART_JOIN_FILTER (table) */
```


**Scenarios**


The four Join Filter hints (`PX_JOIN_FILTER`, `NO_PX_JOIN_FILTER`, `PX_PART_JOIN_FILTER`, and `NO_PX_PART_JOIN_FILTER`) are typically used together with the `leading` and `use_hash` hints. If they are not used in conjunction with these hints, they may become ineffective due to the generation of different join orders or algorithms.

**General Scenarios**


Join Filter hints are generally used together with the `LEADING` and `USE_HASH` hints. Otherwise, they may become ineffective due to the generation of different join orders or algorithms.

First, create a partitioned table:

```sql
CREATE TABLE t1 (
  c1 INT,
  c2 INT,
  c3 INT,
  c4 INT
) PARTITION BY HASH(c1) PARTITIONS 10;
```


**Enforce the Use of Join Filter**


You can use the following SQL statement to enforce the use of a Join Filter:

```sql
EXPLAIN SELECT
/*+ PARALLEL(2) LEADING(a b) USE_HASH(b) PQ_DISTRIBUTE(b BC2HOST NONE)
PX_JOIN_FILTER(b)
PX_PART_JOIN_FILTER(b)
*/ *
FROM t1 a, t1 b WHERE a.c1 = b.c1;
```


Or:

```sql
EXPLAIN SELECT
/*+ PARALLEL(2) LEADING(a b) USE_HASH(b) PQ_DISTRIBUTE(b BC2HOST NONE)
PX_JOIN_FILTER(b a)
PX_PART_JOIN_FILTER(b a)
*/ *
FROM t1 a, t1 b WHERE a.c1 = b.c1;
```


An example of the execution plan output is as follows:


**Multi-table Scenario**


For a three-table join, when the left table is specified as `a`, a Join Filter can be generated for the right table `c`:

```sql
EXPLAIN SELECT
/*+ PARALLEL(2) LEADING(a (b c)) USE_HASH(c (b c)) PQ_DISTRIBUTE((b c) BC2HOST NONE) PQ_DISTRIBUTE(c BC2HOST NONE)
NO_PX_JOIN_FILTER(c)
NO_PX_JOIN_FILTER(b)
NO_PX_PART_JOIN_FILTER(c)
NO_PX_PART_JOIN_FILTER(b)
PX_JOIN_FILTER(c a)
*/ *
FROM t1 a, t1 b, t1 c WHERE a.c1 = c.c1 AND b.c1 = c.c1;
```


An example of the execution plan output is as follows:


Similarly, for a three-table join where the left table is specified as `b`, a Join Filter can be generated for the right table `c`:

```sql
EXPLAIN SELECT
/*+ PARALLEL(2) LEADING(a (b c)) USE_HASH(c (b c)) PQ_DISTRIBUTE((b c) BC2HOST NONE) PQ_DISTRIBUTE(c BC2HOST NONE)
NO_PX_JOIN_FILTER(c)
NO_PX_JOIN_FILTER(b)
NO_PX_PART_JOIN_FILTER(c)
NO_PX_PART_JOIN_FILTER(b)
PX_JOIN_FILTER(c b)
*/ *
FROM t1 a, t1 b, t1 c WHERE a.c1 = c.c1 AND b.c1 = c.c1;
```


An example of the execution plan output is as follows:


**Handling Hint Conflicts**


The `PX_JOIN_FILTER` and `NO_PX_JOIN_FILTER` hints can have four valid forms based on whether the left table `left_tables` is specified. According to the priority, they are matched and used as follows:

| Hint                         | Function                                                         |
|------------------------------|--------------------------------------------------------------|
| NO_PX_JOIN_FILTER( a (b c) ) | When the left table is `(b c)`, prohibits the use of `join filter` for the right table's `a` |
| PX_JOIN_FILTER( a (b c) )    | When the left table is `(b c)`, uses `join filter` for the right table's `a` |
| NO_PX_JOIN_FILTER( a )       | Prohibits the use of `join filter` for the right table's `a` for any left table |
| PX_JOIN_FILTER( a )          | Uses `join filter` for the right table's `a` for any left table |

The conflict handling for `PX_PART_JOIN_FILTER` and `NO_PX_PART_JOIN_FILTER` is the same as for `PX_JOIN_FILTER`.

### NO_USE_HASH

**Purpose:** `NO_USE_HASH` Hint specifies that the optimizer do not use the hash join algorithm when the specified table is the right table in a join. The reverse operation is `USE_HASH`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

#### Documentation section 1: Query block > Join operations

`NO_USE_HASH` Hint specifies that the optimizer do not use the hash join algorithm when the specified table is the right table in a join. The reverse operation is `USE_HASH`.

**Syntax**


```sql
/*+ NO_USE_HASH ( [ @queryblock ] tablespec [ tablespec ]... ) */
```


**Examples**


```sql
-- Use the NO_USE_HASH hint to instruct the optimizer to exclude the use of the hash join algorithm to execute the query.
-- In the join operation between the employees and departments tables, the hash join algorithm is excluded.
SELECT /*+ NO_USE_HASH(e d) */ *
FROM employees e, departments d
WHERE e.department_id = d.department_id;
```

### NO_USE_MERGE

**Purpose:** `NO_USE_MERGE` Hint instructs the optimizer to exclude the use of the merge join algorithm when the specified table is the left table in a join. The reverse operation is `USE_MERGE`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

#### Documentation section 1: Query block > Join operations

`NO_USE_MERGE` Hint instructs the optimizer to exclude the use of the merge join algorithm when the specified table is the left table in a join. The reverse operation is `USE_MERGE`.

**Syntax**


```sql
/*+ NO_USE_MERGE ( [ @queryblock ] tablespec [ tablespec ]... ) */
```


**Examples**


```sql
-- Use the NO_USE_MERGE hint to instruct the optimizer to exclude the use of the sort-merge join algorithm to execute the query.
-- In the join operation between the employees and departments tables, the sort-merge join algorithm is excluded.
SELECT /*+ NO_USE_MERGE(e d) */ *
FROM employees e, departments d
WHERE e.department_id = d.department_id;
```

### NO_USE_NL

**Purpose:** `NO_USE_NL` Hint specifies that the optimizer do not use the nested loop join (NL-JOIN) algorithm when the specified table is the left table in a join. The reverse operation is `USE_NL`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

#### Documentation section 1: Query block > Join operations

`NO_USE_NL` Hint specifies that the optimizer do not use the nested loop join (NL-JOIN) algorithm when the specified table is the left table in a join. The reverse operation is `USE_NL`.

**Syntax**


```sql
/*+ NO_USE_NL ( [ @queryblock ] tablespec [ tablespec ]... ) */
```


**Examples**


```sql
-- Use the NO_USE_NL hint to instruct the optimizer to exclude the use of the nested loop join algorithm to execute the query.
-- In the join operation between the employees and departments tables, the nested loop join algorithm is excluded.
SELECT /*+ NO_USE_NL(e d) */ *
FROM employees e, departments d
WHERE e.department_id = d.department_id;
```

### NO_USE_NL_MATERIALIZATION

**Purpose:** The `NO_USE_NL_MATERIALIZATION` hint forces the optimizer to avoid generating a materialization operator when the specified table is the left table (subtree) to cache data. Its opposite is `USE_NL_MATERIALIZATION`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

#### Documentation section 1: Query block > Join operations

The `NO_USE_NL_MATERIALIZATION` hint forces the optimizer to avoid generating a materialization operator when the specified table is the left table (subtree) to cache data. Its opposite is `USE_NL_MATERIALIZATION`.

**Syntax**


```sql
/*+ NO_USE_NL_MATERIALIZATION ( [ @queryblock ] tablespec [ tablespec ]... ) */
```


**Examples**


```sql
-- Use the NO_USE_NL_MATERIALIZATION hint to prevent the optimizer from materializing the departments table during nested loop joins.
-- This means that the data from the departments table will be accessed each time a nested loop join is performed, rather than using the cached materialized results.
SELECT /*+ NO_USE_NL_MATERIALIZATION(departments) */ *
FROM employees, departments
WHERE employees.department_id = departments.department_id;
```


**Join Filter Hint**


There are four hints related to Join Filter. The first two are used to control the general Join Filter, and the last two are used to control the partial Join Filter:

- `PX_JOIN_FILTER` Hint
- `NO_PX_JOIN_FILTER` Hint
- `PX_PART_JOIN_FILTER` Hint
- `NO_PX_PART_JOIN_FILTER` Hint

Note that these four hints only take effect in parallel execution environments and have no significant effect in non-parallel environments.

The syntax and parameters are as follows:

### PQ_DISTRIBUTE

**Purpose:** The `PQ_DISTRIBUTE` hint specifies how the optimizer distributes data between the producer and consumer servers during parallel query execution. You can use this hint to control the distribution of row data during join or load operations. In parallel query scenarios, especially when handling large volumes of data, `PQ_DISTRIBUTE` can optimize resource usage and improve query performance.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

#### Documentation section 1: Query block > Join operations

The `PQ_DISTRIBUTE` hint specifies how the optimizer distributes data between the producer and consumer servers during parallel query execution. You can use this hint to control the distribution of row data during join or load operations.

In parallel query scenarios, especially when handling large volumes of data, `PQ_DISTRIBUTE` can optimize resource usage and improve query performance.

**Syntax**


```sql
/*+ PQ_DISTRIBUTE
  ( [ @queryblock ] tablespec
    { distribution | outer_distribution inner_distribution }
  ) */
```


**Control join distribution**


You can control the distribution method for joins by specifying one of the following two methods.

As shown in the lower part of the syntax:

* `outer_distribution` specifies the distribution method for the left table.

* `inner_distribution` specifies the distribution method for the right table.

The distribution methods include `HASH`, `BROADCAST`, `PARTITION`, and `NONE`. Only the following six combinations of distribution methods are valid:

|      Distribution Method       |                                                                                             Description                                                                                             |
|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| HASH, HASH      | The optimizer uses a hash function on the join key to map rows from each table to query servers. After mapping, each query server performs a join between a pair of result partitions. This method is recommended when the tables are of comparable size and the join operation is implemented using a hash join or a sort-merge join.                                                                        |
| BROADCAST, NONE | All rows from the right table are broadcasted to each query server. Rows from the left table are randomly partitioned. This method is recommended when the right table is significantly smaller than the left table. Typically, it is also recommended when the size of the left table multiplied by the number of query servers is greater than the size of the right table.                                                                            |
| NONE, BROADCAST | All rows from the left table are broadcasted to each query server. Rows from the right table are randomly partitioned. This method is recommended when the left table is significantly smaller than the right table. Typically, it is also recommended when the size of the left table multiplied by the number of query servers is less than the size of the right table.                                                                            |
| PARTITION, NONE | Rows from the left table are mapped based on partitions of the right table. The left table must be partitioned on the join key. This method is recommended when the number of partitions in the right table is equal to or nearly a multiple of the number of query servers. For example, if the right table has 14 partitions and 15 query servers. 
**Note**  If the left table is not partitioned or if the join is not evenly distributed across the partitions, the optimizer ignores this hint.  |
| NONE, PARTITION | Rows from the right table are mapped based on partitions of the left table. The right table must be partitioned on the join key. This method is recommended when the number of partitions in the right table is equal to or nearly a multiple of the number of query servers. For example, if the right table has 14 partitions and 15 query servers. 
**Note**  If the right table is not partitioned on the join key or if the join is not evenly distributed across the partitions, the optimizer ignores this hint. |
| NONE, NONE      | Each query server performs a join between a pair of matching partitions, one from each table. Both tables must be evenly distributed across the partitions on the join key.   |

**Examples**


The following query example specifies a hash join to join the `r` and `s` tables, and includes a hint that uses the hash distribution method:

```sql
SELECT /*+ORDERED PQ_DISTRIBUTE(s HASH, HASH) USE_HASH (s) */ column_list
FROM r, s
WHERE r.c = s.c;
```


If you want to broadcast the right table `r`, the query statement with the hint is as follows:

```sql
SELECT /*+ORDERED PQ_DISTRIBUTE(s BROADCAST, NONE) USE_HASH (s) */ column_list
FROM r, s
WHERE r.c = s.c;
```

### PX_JOIN_FILTER

**Purpose:** In a parallel execution environment, the `PX_JOIN_FILTER` hint instructs the optimizer to control the use of JOIN FILTER in HASH JOIN. By using this hint, you can specify a particular table as the right table in a hash join and apply the join filter for filtering during execution. The reverse operation of this hint is `NO_PX_JOIN_FILTER`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

**Official example:** The cited hint documentation does not label an official example; none has been invented.

#### Documentation section 1: Query block > Join operations

In a parallel execution environment, the `PX_JOIN_FILTER` hint instructs the optimizer to control the use of JOIN FILTER in HASH JOIN. By using this hint, you can specify a particular table as the right table in a hash join and apply the join filter for filtering during execution. The reverse operation of this hint is `NO_PX_JOIN_FILTER`.

**Syntax**


```sql
/*+ PX_JOIN_FILTER ( [ @qb_name ]  filter_table [ left_tables ] [real_filter_table]) */
```


**Parameters**


- `qb_name`: Specifies the query block where the hint is effective. This is an optional parameter.
- `filter_table`: Describes the single table to which the JOIN FILTER is pushed down. If it's a subquery, this should be the name of the view.
- `left_tables`: Specifies the left table in the HASH-JOIN when allocating the JOIN FILTER. This is an optional parameter.
- `real_filter_table`: The single table in the subquery where the JOIN FILTER is actually pushed down.

### PX_PART_JOIN_FILTER

**Purpose:** The `PX_PART_JOIN_FILTER` hint instructs the optimizer to manually enable PART FILTER. The reverse operation of this hint is `NO_PX_PART_JOIN_FILTER`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

**Official example:** The cited hint documentation does not label an official example; none has been invented.

#### Documentation section 1: Query block > Join operations

The `PX_PART_JOIN_FILTER` hint instructs the optimizer to manually enable PART FILTER. The reverse operation of this hint is `NO_PX_PART_JOIN_FILTER`.

**Syntax**


```sql
/*+ PX_PART_JOIN_FILTER ( [ @qb_name ]  filter_table [ left_tables ] [real_filter_table]) */
```

### USE_HASH

**Purpose:** `USE_HASH` Hint specifies that the optimizer use the hash join algorithm when the specified table is the right table in a join. The reverse operation is `NO_USE_HASH`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Join operations; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Join operations

`USE_HASH` Hint specifies that the optimizer use the hash join algorithm when the specified table is the right table in a join. The reverse operation is `NO_USE_HASH`.

**Syntax**


```sql
/*+ USE_HASH ( [ @queryblock ] tablespec [ tablespec ]... ) */
```


**Examples**


```sql
-- Use the USE_HASH hint to instruct the optimizer to use the hash join algorithm to execute the query.
-- In the join operation between the orders and order_items tables, the orders table is the right table and the order_items table is the left table.
SELECT /*+ USE_HASH(l h) */ *
FROM orders h, order_items l
WHERE l.order_id = h.order_id
  AND l.order_id > 2400;
```

#### Documentation section 2: Shared optimizer guide

The `USE_HASH` hint specifies to use the hash join algorithm for a join when the specified table is the right-side table. The syntax is as follows:

```sql
/*+ USE_HASH(table_name_list) */
```


Here is an example:

```sql
CREATE TABLE t0(c1 INT, c2 INT, c3 INT);
CREATE TABLE t1(c1 INT, c2 INT, c3 INT);

EXPLAIN EXTENDED SELECT /*+LEADING(t0 t1) USE_HASH(t1)*/ *
FROM t0, t1 WHERE t0.c1 = t1.c1;
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

### USE_MERGE

**Purpose:** `USE_MERGE` Hint specifies that the optimizer use the merge join algorithm when the specified table is the right table in a join. The reverse operation is `NO_USE_MERGE`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Join operations; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Join operations

`USE_MERGE` Hint specifies that the optimizer use the merge join algorithm when the specified table is the right table in a join. The reverse operation is `NO_USE_MERGE`.

**Syntax**


```sql
/*+ USE_MERGE ( [ @queryblock ] tablespec [ tablespec ]... ) */
```


**Considerations**


- We recommend that you use the `USE_NL` and `USE_MERGE` hints together with the `LEADING` or `ORDERED` hint.

- If the referenced table is the right table in a join, the optimizer uses these hints.

- If the referenced table is the left table in a join, the optimizer ignores these hints.

- The `USE_MERGE` hint specifies that the optimizer use the merge join algorithm when the specified table is the right table in a join.

- OceanBase Database must have an equijoin condition when it uses the merge join algorithm. Therefore, if you join two tables without an equijoin condition, the `USE_MERGE` hint takes effect.

**Examples**


```sql
-- Use the USE_MERGE hint to instruct the optimizer to use the sort-merge join algorithm to execute the query.
-- In the join operation between the employees and departments tables, the employees table is the right table and the departments table is the left table.
SELECT /*+ USE_MERGE(employees departments) */ *
FROM employees, departments
WHERE employees.department_id = departments.department_id;
```

#### Documentation section 2: Shared optimizer guide

The `USE_MERGE` hint specifies to use the merge join algorithm to join tables, and treats the specified tables as right-side tables. The syntax is as follows:

```sql
/*+ USE_MERGE(table_name_list) */
```


    **Notice**
    In OceanBase Database, a merge join requires an equality join condition. When you join two tables without an equality join condition, the `USE_MERGE` hint is invalid.


Regarding whether the merge join algorithm considers `A Merge Join B` equivalent to `B Merge Join A`, there is currently no definitive conclusion. According to the cost model, the cost of a Merge Join is calculated by distinguishing between the left and right tables, which also increases the flexibility of hints. Therefore, the current implementation of Merge Join differentiates between the left and right tables, meaning that `use_merge` is only effective when the table is used as the right table.

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

### USE_NL

**Purpose:** `USE_NL` Hint specifies that the optimizer use the nested loop join (NL-JOIN) algorithm when the specified table is the left table in a join. The reverse operation is `NO_USE_NL`. - We recommend that you use the `USE_NL` and `USE_MERGE` hints together with the `LEADING` or `ORDERED` hint. - If the referenced table is the left table in a join, the optimizer uses these hints. - If the referenced table is the right table in a join, the optimizer ignores these hints.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Join operations; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Join operations

`USE_NL` Hint specifies that the optimizer use the nested loop join (NL-JOIN) algorithm when the specified table is the left table in a join. The reverse operation is `NO_USE_NL`.

- We recommend that you use the `USE_NL` and `USE_MERGE` hints together with the `LEADING` or `ORDERED` hint.

- If the referenced table is the left table in a join, the optimizer uses these hints.

- If the referenced table is the right table in a join, the optimizer ignores these hints.

**Syntax**


```sql
/*+ USE_NL ( [ @queryblock ] tablespec [ tablespec ]... ) */
```


**Examples**


The following query example shows that the hint forces the use of a nested loop join. The `orders` table is accessed by full table scan, and the filter condition `l.order_id = h.order_id` is applied to each row. For each row that satisfies the filter condition, the `order_items` table is accessed by using the `order_id` index.

```sql
-- Use the USE_NL hint to instruct the optimizer to use the nested loop join algorithm to execute the query.
-- In the join operation between the orders and order_items tables, the orders table is the right table and the order_items table is the left table.
SELECT /*+ USE_NL(l h) */ h.customer_id, l.unit_price * l.quantity
FROM orders h, order_items l
WHERE l.order_id = h.order_id;
```

#### Documentation section 2: Shared optimizer guide

The syntax of a hint that uses a join algorithm is
`join_hint_name ( @ qb_name table_name_list)`
When the right-side table in the join matches `table_name_list`, the optimizer generates a plan based on the hint semantics. Generally, you need to use a `LEADING` hint to specify the join order to make sure that the table in `table_name_list` is the right-side table. Otherwise, the hint becomes invalid as the join order changes.

`table_name_list` supports the following forms:

* USE_NL(t1): uses the nested loop join algorithm when the table `t1` is the right-side table.
* USE_NL(t1 t2 ... ): uses the nested loop join algorithm when the table `t1`, `t2`, or any other one in the list is the right-side table.
* USE_NL((t1 t2)): uses the nested loop join algorithm when the join result of tables `t1` and `t2` is the right-side table. The join order and method of `t1` and `t2` are ignored.
* USE_NL(t1 (t2 t3) (t4 t5 t6) ... ): uses the nested loop join algorithm when the table `t1`, join result of tables `t2` and `t3`, join result of tables `t4`, `t5`, and `t6`, or any other item in the list is the right-side table.

The `USE_NL` hint specifies to use the nested loop join algorithm for a join when the specified table is the right-side table. The syntax is as follows:

```sql
/*+ USE_NL(table_name_list) */
```


Here is an example:

```sql
CREATE TABLE t0(c1 INT, c2 INT, c3 INT);
CREATE TABLE t1(c1 INT, c2 INT, c3 INT);
CREATE TABLE t2(c1 INT, c2 INT, c3 INT);

EXPLAIN EXTENDED SELECT /*+LEADING(t0 t1) USE_NL(t1)*/ *
FROM t0, t1 WHERE t0.c1 = t1.c1;
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/100.basic-elements-of-mysql-mode/600.custom-variables-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/100.basic-elements-of-mysql-mode/600.custom-variables-of-mysql-mode.md)
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/1300.alter-outline-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/600.sql-statement-of-mysql-mode/1300.alter-outline-of-mysql-mode.md)

### USE_NL_MATERIALIZATION

**Purpose:** The `USE_NL_MATERIALIZATION` hint forces the optimizer to generate a materialization operator when the specified table is the left table (subtree) to cache data. Its opposite is `NO_USE_NL_MATERIALIZATION`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Join operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/300.hints-related-to-join-operations-of-oracle-mode.md)

#### Documentation section 1: Query block > Join operations

The `USE_NL_MATERIALIZATION` hint forces the optimizer to generate a materialization operator when the specified table is the left table (subtree) to cache data. Its opposite is `NO_USE_NL_MATERIALIZATION`.

**Syntax**


```sql
/*+ USE_NL_MATERIALIZATION ( [ @queryblock ] tablespec [ tablespec ]... ) */
```


**Examples**


```sql
-- Use the USE_NL_MATERIALIZATION hint to instruct the optimizer to materialize the departments table during nested loop joins.
SELECT /*+ USE_NL_MATERIALIZATION(departments) */ *
FROM employees, departments
WHERE employees.department_id = departments.department_id;
```

## Query block > Join order

### JOIN_ORDER

**Purpose:** Documented as example-only evidence: JOIN_ORDER appears in an official MySQL-mode JSON_TABLE example with the table order jt, t1. The 4.4.2 SQL Reference does not provide a dedicated JOIN_ORDER syntax, parameter, or behavior page.

**Mode documentation:** MySQL mode (official JSON_TABLE example only).

**Category:** Query block > Join order.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/400.functions-of-mysql-mode/700.json-functions-of-mysql-mode/450.json-table-functions-of-mysql-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/200.common-tenant-of-mysql-mode/400.functions-of-mysql-mode/700.json-functions-of-mysql-mode/450.json-table-functions-of-mysql-mode.md)

#### Documentation section 1: Query block > Join order

**Documentation status**

`JOIN_ORDER` occurs in an official MySQL-mode `JSON_TABLE` example. The example uses the order `jt, t1`. No dedicated 4.4.2 reference section defines a general `JOIN_ORDER` grammar, accepted options, or its relationship to `LEADING`; therefore this entry is classified as **example-only evidence**, not as a fully specified independent hint interface.

**Official example**

```sql
SELECT /*+ JOIN_ORDER(jt, t1) */ id, jt.*
FROM t1,
     JSON_TABLE(
         jd, '$[*]' COLUMNS (
             jid FOR ORDINALITY,
             val INT PATH '$'
         )
     ) AS jt;
```

### LEADING

**Purpose:** The `LEADING` hint instructs the optimizer to join tables in the specified order, offering greater flexibility compared to the `ORDERED` hint. The `LEADING` hint allows you to explicitly define any valid expected join order. In contrast, the `ORDERED` hint can only specify a specific join order, which may be affected by rewriting. We recommend using the `LEADING` hint to explicitly define the expected join order.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Join order; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/200.hint-related-to-the-join-order-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/200.hint-related-to-the-join-order-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Join order

The `LEADING` hint instructs the optimizer to join tables in the specified order, offering greater flexibility compared to the `ORDERED` hint. The `LEADING` hint allows you to explicitly define any valid expected join order. In contrast, the `ORDERED` hint can only specify a specific join order, which may be affected by rewriting. We recommend using the `LEADING` hint to explicitly define the expected join order.

**Syntax**


```sql
/*+ LEADING ( [ @queryblock ] tablespec [ tablespec ]...  ) */
```


**Considerations**


The `LEADING` hint takes effect only when the specified table name matches the table name in the query.

* If the specified `table_name` does not exist, the `LEADING` hint is ineffective.

* If the hint contains duplicate tables, the `LEADING` hint is ineffective.

* If the optimizer cannot find the corresponding table during join optimization, the join order specified for this table and subsequent tables is ineffective, while the join order specified for tables before this one remains valid.

* If the join graph's dependencies prevent the specified tables from being joined in the specified order first, the `LEADING` hint is ineffective.

* If two or more conflicting `LEADING` hints are specified, the `LEADING` hint is ineffective.

* If the `ORDERED` hint is specified, it will override all `LEADING` hints.

**Examples**


```sql
SELECT /*+ LEADING(e j) */ *
FROM employees e, departments d, job_history j
WHERE e.department_id = d.department_id
  AND e.hire_date = j.start_date;

-- View the execution plan
EXPLAIN SELECT /*+ LEADING(e j) */ *
FROM employees e, departments d, job_history j
WHERE e.department_id = d.department_id
  AND e.hire_date = j.start_date;
```


In the execution plan above, `LEADING(e j)` indicates that the optimizer considers the `e (employees)` table first, then the `j (job_history)` table.

#### Documentation section 2: Shared optimizer guide

The `LEADING` hint can specify the join order of tables. The syntax is as follows:

```sql
/*+ LEADING(table_name_list) */
```


In `table_name_list`, `()` can be used to indicate the join priority among tables, allowing for the specification of complex joins. An example is as follows:

```sql
EXPLAIN BASIC SELECT /*+LEADING(d c b a)*/ * FROM t1 a, t1 b, t1 c, t1 d;
```


To ensure that the join is performed in the order specified by the user, the `LEADING` hint is checked quite strictly. If the `table_name` specified in the hint does not exist, the `LEADING` hint becomes invalid. If duplicate tables are found in the hint, the `LEADING` hint also becomes invalid. During the optimizer's join process, if the `table_id` cannot be matched to a corresponding table in the From Items, rewriting may occur, causing the specified `JOIN` order for that table and the tables following it to become invalid. However, the `JOIN` order for the tables preceding it remains valid.

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

### ORDERED

**Purpose:** The connection sequence in the query uses the default connection sequence. The `ORDERED` hint has higher priority than the `LEADING` hint. When the `ORDERED` hint exists, the `LEADING` hint is ignored. When you use the `ORDERED` hint, the `ORDERED` hint does not appear in the OUTLINE DATA. Instead, the entire `LEADING` hint is displayed.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Join order; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/200.hint-related-to-the-join-order-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/200.hint-related-to-the-join-order-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Join order

The connection sequence in the query uses the default connection sequence. The `ORDERED` hint has higher priority than the `LEADING` hint. When the `ORDERED` hint exists, the `LEADING` hint is ignored.
When you use the `ORDERED` hint, the `ORDERED` hint does not appear in the OUTLINE DATA. Instead, the entire `LEADING` hint is displayed.

**Syntax**


```sql
/*+ ORDERED */
```


**Examples**


Let's assume that the `employees`, `departments`, and `job_history` tables need to be joined:

```sql
SELECT /*+ ORDERED */ e.employee_id, d.department_name, j.job_id
FROM employees e, departments d, job_history j
WHERE e.department_id = d.department_id
  AND e.hire_date = j.start_date;
```


In this example, the database joins the three tables in this order: `employees`, `departments`, and `job_history`.

#### Documentation section 2: Shared optimizer guide

The `ORDERED` hint can specify the join order according to the sequence of tables following the `FROM` clause. The syntax is as follows:

```sql
/*+ ORDERED */
```


If SQL rewriting occurs after specifying this hint, the join will follow the order of the from items in the rewritten `stmt`, as subqueries will be replaced with new table items in their corresponding positions during the rewrite.

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

## Query block > Other transformation

### DECORRELATE

**Purpose:** The `DECORRELATE` hint enables a query rewrite that decorrelates lateral tables in the query. A correlated subquery is a subquery whose output depends on the outer query. A decorated subquery is a subquery that is independent of the outer query. The reverse operation of the `DECORRELATE` hint is the `NO_DECORRELATE` hint, which disables the de-correlation rewriting of lateral tables.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Other transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/400.hints-related-to-other-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/400.hints-related-to-other-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Other transformation

The `DECORRELATE` hint enables a query rewrite that decorrelates lateral tables in the query. A correlated subquery is a subquery whose output depends on the outer query. A decorated subquery is a subquery that is independent of the outer query.

The reverse operation of the `DECORRELATE` hint is the `NO_DECORRELATE` hint, which disables the de-correlation rewriting of lateral tables.

**Syntax**


```sql
/*+ DECORRELATE [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the name of the query block that the optimizer is to unwrite.

**Example**


In the following query example, the `DECORRELATE` Hint is used to enable the rewriting of lateral table queries into a decorrelated form.

```sql
-- The `NO_MERGE` hint, when used with the `DECORRELATE` keyword, ensures that the subquery will not be merged with the outer query, and explicitly requests the optimizer to decorrelate the subquery.
SELECT *
FROM t1, LATERAL (SELECT /*+ NO_MERGE DECORRELATE */ *
                  FROM t2
                  WHERE t2.c2 = t1.c1) v
WHERE v.c1 = 1;
```

### NO_DECORRELATE

**Purpose:** This is the reverse of the `DECORRELATE` hint. The `NO_DECORRELATE` hint disables lateral table decorrelation rewriting.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Other transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/400.hints-related-to-other-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/400.hints-related-to-other-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Other transformation

This is the reverse of the `DECORRELATE` hint. The `NO_DECORRELATE` hint disables lateral table decorrelation rewriting.

**Syntax**


```sql
/*+ NO_DECORRELATE [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the name of a query block to be excluded from query rewrite.

**Examples**


The following query examples use the `NO_DECORRELATE` hint to disable lateral table query decorrelation rewriting.

```sql
The `NO_MERGE` hint is used with the `NO_DECORRELATE` hint to ensure that the optimizer does not merge subqueries into the outer query and does not rewrite correlated subqueries.
SELECT *
FROM t1, LATERAL (SELECT /*+ NO_MERGE NO_DECORRELATE */ *
                  FROM t2
                  WHERE t2.c2 = t1.c1) v
WHERE v.c1 = 1;
```

## Query block > Set operations

### NO_USE_HASH_SET

**Purpose:** The `NO_USE_HASH_SET` hint specifies the algorithm to be used for set operations. The opposite of this hint is `USE_HASH_SET`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Set operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/700.hints-related-to-set-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/700.hints-related-to-set-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > Set operations

The `NO_USE_HASH_SET` hint specifies the algorithm to be used for set operations. The opposite of this hint is `USE_HASH_SET`.

**Syntax**


```sql
/*+ NO_USE_HASH_SET [ ( [ @ qb_name ] ) ] */
```


**Examples**


The following query example shows how to use the `NO_USE_HASH_SET` hint to prevent the use of the hash algorithm. OceanBase Database supports both the hash algorithm and the merge algorithm for set operations. After you use the `NO_USE_HASH_SET` hint, the merge algorithm is used for set operations. The `UNION ALL` set operation does not have deduplication semantics and is not affected by this hint.

```sql
-- Use the NO_USE_HASH_SET hint to instruct the optimizer to avoid using the hash method in set operations.
EXPLAIN BASIC
SELECT /*+ NO_USE_HASH_SET(@set$1) */ c1, c2, c3 FROM t1
UNION
SELECT c1, c2, c3 FROM t1;
```

### PQ_SET

**Purpose:** The `PQ_SET` hint specifies the data distribution method for set operations during distributed execution.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Set operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/700.hints-related-to-set-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/700.hints-related-to-set-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > Set operations

The `PQ_SET` hint specifies the data distribution method for set operations during distributed execution.

**Syntax**


```sql
PQ_SET ( [ @qb_name ] [left_branch_qb_name] method_list )
```


**Parameters**


- `left_branch_qb_name`: specifies the left branch of the `UNION` or `INTERSECT` operation.

- `method_list` specifies the distributed execution method.

The following table describes the distributed execution methods and provides examples.

| Data distribution method | Outline data hint description | Description |
|----------------------|------------------------------|-----------|
| DIST_BASIC_METHOD    | PQ_SET ( @SET$1 ), and no hint is added to the outline |           |
| DIST_PARTITION_WISE  |   PQ_SET ( @SET$1 NONE NONE)   |    |
|DIST_PULL_TO_LOCAL    |  PQ_SET ( @SET$1 LOCAL LOCAL)  |    |
|DIST_SET_RANDOM       |  PQ_SET ( @SET$1 RANDOM NONE)  |  Only applicable to `UNION ALL`   |
|DIST_SET_RANDOM       |  PQ_SET ( @SET$1 NONE RANDOM)|  Only applicable to `UNION ALL`   |
|DIST_SET_RANDOM       |  PQ_SET ( @SET$1 RANDOM NONE RANDOM)|  Only applicable to `UNION ALL`   |
|DIST_HASH_HASH        | PQ_SET ( @SET$1 SEL$1 HASH HASH)|  Only applicable to two-branch union/intersect operations, with SEL$1 as the left branch  |
|DIST_NONE_PARTITION   | PQ_SET ( @SET$1 SEL$2 NONE PARTITION )| Only applicable to two-branch union/intersect operations, with SEL$2 as the left branch|
|DIST_PARTITION_NONE   | PQ_SET ( @SET$1 SEL$1 PARTITION NONE )|Only applicable to two-branch union/intersect operations, with SEL$1 as the left branch|

**Examples**


The following query example uses `pq_set(@set$1 local local)` to specify that data is directly pulled back to the local node for distributed execution, uses `pq_set(@set$1 sel$2 hash hash)` to specify the use of the `HASH` method for redistributing data for set operations, and uses `sel$2` as the left side of the set operation.

```sql
-- Specify by using the PQ_SET hint that the query uses specific parallel execution mode for set operations
CREATE TABLE tp1(c1 INT, c2 INT, c3 INT) PARTITION BY HASH(c1) PARTITIONS 10;
EXPLAIN BASIC SELECT /*+ PQ_SET(@set$1 local local) */ c2, c3 FROM tp1 a UNION SELECT c2, c3 FROM tp1 b;
```

### USE_HASH_SET

**Purpose:** The `USE_HASH_SET` hint specifies the algorithm to use for set operations. The opposite of this hint is `NO_USE_HASH_SET`.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Set operations.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/700.hints-related-to-set-hints-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/700.hints-related-to-set-hints-of-oracle-mode.md)

#### Documentation section 1: Query block > Set operations

The `USE_HASH_SET` hint specifies the algorithm to use for set operations. The opposite of this hint is `NO_USE_HASH_SET`.

**Syntax**


```sql
/*+ USE_HASH_SET [ ( [ @ qb_name ] ) ] */
```


**Examples**


The following query example shows how to use the `USE_HASH_SET` hint to specify the `HASH` algorithm for set operations.

```sql
-- Use the USE_HASH_SET hint to force the use of the HASH method for set operations.
EXPLAIN BASIC
SELECT /*+ USE_HASH_SET(@set$1) */ c1, c2, c3 FROM t1
UNION
SELECT c1, c2, c3 FROM t1;
```

## Query block > Statement transformation

### NO_REWRITE

**Purpose:** The `NO_REWRITE` hint prevents query rewriting. After using this hint, the query block it affects will not participate in any query rewriting operations.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Statement transformation.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/100.hints-related-to-stmt-transform-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/300.transform-hint-of-oracle-mode/100.hints-related-to-stmt-transform-hint-of-oracle-mode.md)

#### Documentation section 1: Query block > Statement transformation

The `NO_REWRITE` hint prevents query rewriting. After using this hint, the query block it affects will not participate in any query rewriting operations.

**Syntax**


```sql
/*+ NO_REWRITE [ ( [ @ qb_name ] ) ] */
```


**Parameters**


- `@qb_name`: Optional. Specifies the name of the query block to which the `NO_REWRITE` attribute is applied. If you do not specify a query block name, the hint affects the entire SQL statement.

**Examples**


```sql
-- The following query does not perform view merging because the NO_REWRITE hint is specified.
SELECT /*+ NO_REWRITE */ * FROM (SELECT * FROM t1);
```


Although the `NO_REWRITE` hint prevents query rewriting, you can combine it with other query rewriting hints to allow specific types of query rewriting. For example, you can use the `MERGE` hint in an inner query block to specify view merging rewriting, even if the outer query block uses the `NO_REWRITE` hint.

```sql
-- The outer query uses the NO_REWRITE hint, so no automatic rewriting is performed.
SELECT /*+ NO_REWRITE */
    *
FROM
    (SELECT /*+ MERGE */ * FROM t1) -- The inner query uses the MERGE hint to force view merging rewriting
WHERE
    t1.column1 = 'somevalue';
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

## Query block > Subquery

### NO_PUSH_SUBQ

**Purpose:** **Note** For OceanBase Database V4.3.5, the `NO_PUSH_SUBQ` hint is supported starting from V4.3.5 BP2. The `NO_PUSH_SUBQ` hint is the opposite of the `PUSH_SUBQ` hint. It instructs the optimizer to execute subqueries that have not been rewritten as joins at the end. It is applicable when the subquery has high cost or cannot significantly reduce the number of rows. Applicable scenarios include: * The subquery has high execution cost or its result does not significantly reduce the number of rows. * The subquery needs to be executed after other filtering conditions take effect to reduce the amount of input data.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Subquery; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/450.hints-related-to-subquery-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/450.hints-related-to-subquery-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Subquery

**Note**
  For OceanBase Database V4.3.5, the `NO_PUSH_SUBQ` hint is supported starting from V4.3.5 BP2.


The `NO_PUSH_SUBQ` hint is the opposite of the `PUSH_SUBQ` hint. It instructs the optimizer to execute subqueries that have not been rewritten as joins at the end. It is applicable when the subquery has high cost or cannot significantly reduce the number of rows. Applicable scenarios include:

* The subquery has high execution cost or its result does not significantly reduce the number of rows.
* The subquery needs to be executed after other filtering conditions take effect to reduce the amount of input data.

**Syntax:**

```sql
/*+ NO_PUSH_SUBQ[(@qb_name)] */
```


Parameter description:

* `@qb_name`: Optional. Specifies the alias for the subquery.

**Example:**

Use the `NO_PUSH_SUBQ` hint in a query to instruct the optimizer to execute the subquery at the end.

```sql
SELECT /*+ NO_PUSH_SUBQ */ *
FROM tbl1, tbl2
WHERE tbl1.col1 = (SELECT MAX(tbl3.col1)
                   FROM tbl3
                   WHERE tbl3.col2 = tbl2.col2);
```

#### Documentation section 2: Shared optimizer guide

**Note**
  For OceanBase Database V4.3.5, support for the `NO_PUSH_SUBQ` hint was introduced starting from V4.3.5 BP2.


The `NO_PUSH_SUBQ` hint is the opposite of the `PUSH_SUBQ` hint. It instructs the optimizer to execute subqueries that have not been rewritten into joins at the end of the execution plan. This is suitable for scenarios where subquery execution is costly or does not significantly reduce the number of rows. Applicable scenarios include:

* The execution cost of the subquery is high, or its results have little impact on reducing the data volume.
* The subquery should be executed after other filtering conditions have been applied to reduce its input data size.

**Syntax:**

```sql
/*+ NO_PUSH_SUBQ[(@qb_name)] */
```


Parameter explanation:

* `@qb_name`: An optional parameter that specifies the alias of the subquery.

**Example:**

In the following query, the `NO_PUSH_SUBQ` hint is used to instruct the optimizer to delay the execution of the subquery until the end:

```sql
SELECT /*+ NO_PUSH_SUBQ */ *
FROM tbl1, tbl2
WHERE tbl1.col1 = (SELECT MAX(tbl3.col1)
                   FROM tbl3
                   WHERE tbl3.col2 = tbl2.col2);
```


**References**


For more information about hints, see [Overview of hints](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/100.hint-overview-of-oracle-mode.md).

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

### PQ_SUBQUERY

**Purpose:** The `PQ_SUBQUERY` hint provides fine-grained control over the behavior of subqueries in parallel processing, indicating how the optimizer should handle subqueries in a parallel query (PQ) environment, especially when dealing with distributed data distribution. The `PQ_SUBQUERY` hint includes two main control modes: non-precise control and precise control.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL applicability not separately enumerated.

**Category:** Query block > Subquery.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/450.hints-related-to-subquery-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/450.hints-related-to-subquery-of-oracle-mode.md)

#### Documentation section 1: Query block > Subquery

The `PQ_SUBQUERY` hint provides fine-grained control over the behavior of subqueries in parallel processing, indicating how the optimizer should handle subqueries in a parallel query (PQ) environment, especially when dealing with distributed data distribution.

The `PQ_SUBQUERY` hint includes two main control modes: non-precise control and precise control.

**Non-precise control**


**Syntax**


```sql
/*+ PQ_SUBQUERY ([ @qb_name ] [table_list] [op_order_no] sub_qb_name_list method_list) */
```


**Parameter description**


- `@qb_name`: Optional. Specifies the alias for the current query block.
- `table_list`: Optional. Specifies the list of tables, used only in the subplan filter method for joins.
- `op_order_no`: The sequence number of the operation node.
- `sub_qb_name_list`: The list of aliases for the subquery blocks.
- `method_list`: The distributed data distribution method. The specific distribution methods are as follows:
  - `DIST_BASIC_METHOD`: No specific method is specified.
  - `DIST_PARTITION_WISE`: Data is distributed by partition, using the `NONE NONE` method.
  - `DIST_PULL_TO_LOCAL`: Data is pulled to the local node, using the `LOCAL LOCAL` method.
  - `DIST_PARTITION_NONE`: Partitioning is performed, but no subsequent method is specified, using `PARTITION NONE`.
  - `DIST_NONE_ALL`: No partitioning is performed, and data is broadcasted to all nodes, using `NONE ALL`.

**Example**


```sql
PQ_SUBQUERY(@SEL$1 0 SEL$1 PARTITION NONE) -- Can be omitted as PQ_SUBQUERY(SEL$1)
PQ_SUBQUERY(@SEL$1 1 SEL$2 PARTITION NONE)

CREATE TABLE t1(c1 INT, c2 INT, c3 INT, c4 INT)
    PARTITION BY HASH(c1) PARTITIONS 10;

EXPLAIN
SELECT
  (SELECT t_inner.c1 FROM t1 t_inner WHERE t_inner.c1 = t_outer.c3) AS a
FROM t1 t_outer
ORDER BY c3;
```


The result is as follows:


**Precise control**


**Syntax**


```sql
/*+ PQ_SUBQUERY ([ @qb_name ] win_group ...) */
```


**Parameter description**


- `win_group`: (List of indices) Declares the grouping and internal behavior of window functions.
  - `dist_method`: Specifies the distributed execution method, with the same optional values as above.
  - `PARTITION_SORT`: Whether to apply the partition sort algorithm when using hash distributed execution (`HASH`) or no distributed execution (`NONE`). Default is not to use it.
  - `PUSHDOWN`: Whether to apply window function pushdown when using hash distributed execution.

**Example**


```sql
PQ_SUBQUERY (@SEL$1 (t_a t_b t_c) 0 SEL$2 PARTITION NONE)
-- Can be omitted as PQ_SUBQUERY ((t_a t_b t_c) SEL$2 PARTITION NONE)

EXPLAIN
SELECT /*+ PQ_SUBQUERY (@SEL$1 (t_a, t_b, t_c) 0 SEL$2 PARTITION NONE) */
  t_a.c1 AS a_c1,
  t_b.c1 AS b_c1,
  t_c.c1 AS c_c1,
  t_d.c1 AS d_c1
FROM t1 t_a
LEFT JOIN t1 t_b ON t_a.c3 = t_b.c4
INNER JOIN t1 t_c ON t_a.c1 = t_c.c1
RIGHT JOIN t1 t_d ON t_a.c3 = t_d.c4
WHERE t_a.c1 = t_d.c3
  AND t_c.c2 + (SELECT c4 FROM t1 WHERE c1 = t_c.c3 AND c2 = t_a.c2 AND c3 = t_b.c1) = t_a.c3;
```


The result is as follows:

### PUSH_SUBQ

**Purpose:** **Note** For OceanBase Database V4.3.5, the `PUSH_SUBQ` hint is supported starting from V4.3.5 BP2. The `PUSH_SUBQ` hint instructs the optimizer to execute subqueries that have not been rewritten as joins as early as possible. Typically, these subqueries, if not rewritten as joins, are executed after all table joins in the execution plan. If a subquery has low computational cost and can filter a large amount of data, executing it early may improve plan performance. However, if the subquery is rewritten as a join (`/+unnest/`), this hint is ineffective. Applicable scenarios include: * The subquery has low execution cost but can quickly filter a large amount of data. * The results of the subquery need to be used early to narrow down the data scope.

**Mode documentation:** Oracle mode (dedicated chapter); MySQL-mode evidence also present.

**Category:** Query block > Subquery; Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/450.hints-related-to-subquery-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/200.hint-list-of-oracle-mode/200.optimizer-hint-of-oracle-mode/450.hints-related-to-subquery-of-oracle-mode.md)
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Query block > Subquery

**Note**
  For OceanBase Database V4.3.5, the `PUSH_SUBQ` hint is supported starting from V4.3.5 BP2.


The `PUSH_SUBQ` hint instructs the optimizer to execute subqueries that have not been rewritten as joins as early as possible. Typically, these subqueries, if not rewritten as joins, are executed after all table joins in the execution plan. If a subquery has low computational cost and can filter a large amount of data, executing it early may improve plan performance. However, if the subquery is rewritten as a join (`/+unnest/`), this hint is ineffective. Applicable scenarios include:

* The subquery has low execution cost but can quickly filter a large amount of data.
* The results of the subquery need to be used early to narrow down the data scope.

**Syntax:**

```sql
/*+ PUSH_SUBQ[(@qb_name)] */
```


Parameter description:

* `@qb_name`: Optional. Specifies the alias for the subquery (detailed information can be found in the **QB_NAME Parameter** section above). It is used to clarify the target of the hint. If omitted, the default is to apply the hint to the subquery in which it is placed.

**Example:**

Use the `PUSH_SUBQ` hint in a query to instruct the optimizer to execute the subquery early, to filter data in the `tbl1` table in advance.

```sql
SELECT /*+ PUSH_SUBQ(@"SEL$2") */ *
FROM tbl1, tbl2
WHERE tbl1.col1 = (SELECT MAX(tbl3.col1)
                   FROM tbl3
                   WHERE tbl3.col2 = tbl2.col2);
```

#### Documentation section 2: Shared optimizer guide

**Note**
  For OceanBase Database V4.3.5, support for the `PUSH_SUBQ` hint was introduced starting from V4.3.5 BP2.


The `PUSH_SUBQ` hint is used to instruct the optimizer to execute subqueries that have not been rewritten into joins as early as possible. Typically, these subqueries, if not rewritten into joins, are executed after all table joins in the execution plan. If the subquery has a low computation cost and can filter out a large amount of data, executing it earlier may improve the performance of the plan. However, note that if the subquery is rewritten into a join (via `/*+ unnest */`), this hint becomes invalid. Applicable scenarios include:

* The subquery's execution cost is low but can quickly filter out a large amount of data.
* The results of the subquery need to be utilized early to narrow down the data range.

**Syntax:**

```sql
/*+ PUSH_SUBQ[(@qb_name)] */
```


Parameter explanation:

* `@qb_name`: An optional parameter that specifies the alias of the subquery (for more details, refer to the **QB_NAME Parameter** section above). This is used to explicitly indicate the target of the hint. If omitted, the hint applies to the subquery where it is located by default.

**Example:**

In the following query, the `PUSH_SUBQ` hint is used to instruct the optimizer to execute the subquery early, allowing it to filter data from the `tbl1` table in advance:

```sql
SELECT /*+ PUSH_SUBQ(@"SEL$2") */ *
FROM tbl1, tbl2
WHERE tbl1.col1 = (SELECT MAX(tbl3.col1)
                   FROM tbl3
                   WHERE tbl3.col2 = tbl2.col2);
```

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

## Shared optimizer guide

### UNION_MERGE

**Purpose:** Requests an index-merge execution method. With a valid UNION_MERGE hint, OceanBase directly selects the corresponding index-merge plan; supported since V4.3.5 BP1 and therefore included in the V4.4.2 documentation.

**Mode documentation:** Shared optimizer guide; MySQL SELECT documentation references this guide.

**Category:** Shared optimizer guide.

**Official sources:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

#### Documentation section 1: Shared optimizer guide

**Note**
  For OceanBase Database V4.3.5, support for the `UNION_MERGE` hint was introduced starting from V4.3.5 BP1.


The `UNION_MERGE` hint is used to specify the execution method of using index merge in the query plan. When a valid `UNION_MERGE` hint is provided, OceanBase Database will directly select the corresponding Index Merge plan.

The syntax is as follows:

```sql
/*+ UNION_MERGE(table_name index_name_list) */
```


Parameter explanation:

- `table_name`: Specifies the name of the table.
- `index_name_list`: Specifies a list of index names, with multiple index names separated by spaces.

**Here is an example:**

1. Create a table named `tbl1` that contains full-text indexes.

```sql
CREATE TABLE tbl1 (
        col1 INT PRIMARY KEY,
        col2 INT,
        col3 VARCHAR(100),
        col4 VARCHAR(100),
        FULLTEXT INDEX ftidx3(col3),
        FULLTEXT INDEX ftidx4(col4)
    );
```


2. Use the `UNION_MERGE` hint to query the execution plan. Add the hint to the query statement to specify to use index merge for the full-text indexes `ftidx3` and `ftidx4` of the `tbl1` table.

```sql
EXPLAIN SELECT /*+UNION_MERGE(tbl1 ftidx3 ftidx4)*/ * FROM tbl1
        WHERE col1 = 1
        AND (MATCH(col3) AGAINST ("word1") OR MATCH(col4) AGAINST ("word1"));
```


    The return result is as follows:


    In the query result:

    * `DISTRIBUTED INDEX MERGE SCAN`: indicates that the index merge scan method is used in a distributed environment.
    * `is_index_back=true`: indicates that a table access by index key operation is enabled.
    * `use_index_merge=true`: indicates that the index merge method is enabled.
    * `filter_before_indexback[false,false]`: indicates that the filtering condition is not applied before the table access by index key operation.

**MySQL-mode evidence:**
- [en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/1000.performance-tuning-guide/500.sql-optimization/400.sql-optimization/700.manage-execution-plans/100.optimizer-hint.md)

## Tracing

### TRACE_LOG

**Purpose:** Enables SQL Trace for only the current statement carrying the hint; SHOW TRACE can then return execution trace information for the last SQL statement.

**Mode documentation:** Mode not specified on the source page.

**Category:** Tracing.

**Official sources:**
- [en-US/600.manage/800.logging/600.view-logs/200.search-for-logs-of-a-sql-query-using-trace.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/600.manage/800.logging/600.view-logs/200.search-for-logs-of-a-sql-query-using-trace.md)

#### Documentation section 1: Tracing

**Purpose and statement scope**

Set the `trace_log` field in a hint to enable SQL Trace for only the current statement. This is one of the documented ways to enable SQL Trace; the alternative session variable affects subsequent statements in the session.

**Syntax**

```sql
/*+ TRACE_LOG=ON */
```

**Official example**

```sql
SELECT /*+ TRACE_LOG=ON */ c1 FROM t1 LIMIT 2;
SHOW TRACE;
```

The source does not enumerate additional `trace_log` values on this page.

## Appendix A: Outline-data structure

| Hint name                               | Description                            |
|---------------------------------------|----------------------------------|
| `BEGIN_OUTLINE_DATA`                  |  Outline data start marker.            |
| `END_OUTLINE_DATA`                    |  Outline data end marker.           |
| `QB_NAME`                             |  Specifies a name for a query block to be referenced in other hints. |
| `OPTIMIZER_FEATURES_ENABLE`           |  Specifies the optimizer version for query plan generation.             |

**OUTLINE DATA structure**


**OUTLINE DATA** identifies hints during query optimization. Here is an example of a valid OUTLINE DATA structure:

```sql
SELECT /*+PARALLEL(2)*/ 1
FROM (SELECT c2 FROM t1 WHERE c1 = 1) v, t2
WHERE t2.c2 = v.c2;

/*+
  BEGIN_OUTLINE_DATA
  // Optimization hints
  LEADING(@"SEL$6D1A4751" ("TEST.T1"@"SEL$2" "TEST.T2"@"SEL$1"))
  USE_HASH(@"SEL$6D1A4751" "TEST.T2"@"SEL$1")
  PQ_DISTRIBUTE(@"SEL$6D1A4751" "TEST.T2"@"SEL$1" NONE BROADCAST)
  PX_JOIN_FILTER(@"SEL$6D1A4751" "TEST.T2"@"SEL$1")
  FULL(@"SEL$6D1A4751" "TEST.T1"@"SEL$2")
  FULL(@"SEL$6D1A4751" "TEST.T2"@"SEL$1")
  // Transformation hints
  MERGE(@"SEL$2" > "SEL$1")
  // Global hints
  OPTIMIZER_FEATURES_ENABLE('4.0.0.0')
  PARALLEL(2)
  END_OUTLINE_DATA
*/
```


Hints between `BEGIN_OUTLINE_DATA` and `END_OUTLINE_DATA` that include the `OPTIMIZER_FEATURES_ENABLE` hint and specify a valid optimizer version are recognized as OUTLINE DATA.

`BEGIN_OUTLINE_DATA` and `END_OUTLINE_DATA` delimit serialized outline data. They are covered here for completeness but are not counted as independent query-hint names.

## Appendix B: Official hint-overview rules

A hint is a comment in an SQL statement that passes instructions to the OceanBase Database optimizer. You can use hints to make the optimizer generate a specified execution plan.

Generally, a hint is not required because the optimizer selects the best execution plan for a query. In some scenarios, the execution plan generated by the optimizer may not meet user requirements. In this case, you need to add a hint to specify and generate a specific execution plan.

It is important to note that you need to only consider using hints with caution after collecting the relevant table statistics and evaluating the optimizer's plan using the `EXPLAIN PLAN` statement without any hints. Changes to database conditions or enhancements to query performance in future versions may cause the hints in your code to have a significant impact on performance.

**How to use hints**


**Considerations**


A statement can contain only one hint comment, and this comment must immediately follow the `CREATE`, `SELECT`, `UPDATE`, `INSERT`, `REPLACE`, or `DELETE` keyword. Hints only affect the logic of the execution plan generated by the optimizer and do not alter the semantics of the SQL statement.

- **The syntax for using hints in statement comments is as follows:**

```sql
{CREATE|DELETE|INSERT|SELECT|UPDATE|REPLACE} /*+ hint_text [,hint_text...] */
```


- **Some rules to note when defining hints:**

- Syntactically, a hint is a special type of SQL comment that starts with `/*+` and does not allow spaces after the `/*`. If the server cannot recognize the hint in the SQL statement, the optimizer will ignore the user-specified hint and use the default execution plan.

* Only one hint comment can be added after each `SELECT` or similar keyword, but this hint comment can contain multiple hints. There may or may not be a space between the `+` in `/*+` and the hint text. If multiple hints are included in the comment, they must be separated by at least one space.

  In the example below, `/*+ hint1 */` and `/*+ hint3 hint4 */` are valid hints, while `/*+ hint2 */` is invalid.

```sql
select /*+ hint1 */ /*+ hint2 */ * from t1, (select /*+ hint3 hint4 */ t2.* from t2, t3) v where t1.c1 = v.c1;
```


* For queries where multiple positions allow hints, you can use multiple hint comments within the query.

* Hints that contain spelling or syntax errors will be ignored. However, the database will still consider other correctly specified hints within the same comment.

* Hints that do not immediately follow the `CREATE`, `DELETE`, `INSERT`, `REPLACE`, `SELECT`, or `UPDATE` keywords are invalid.

* If hints within a comment conflict with each other, those hints are invalid. However, the database will still consider other non-conflicting hints within the same comment.

* Because hints are added as comments in queries, some clients or drivers may remove comments from queries, causing the hints to become ineffective.

**Define a query block in a hint**


You can specify which query block a hint applies to by defining an optional query block name in many hints. For more information, see [Using query block name and QB_NAME hint to control query optimization](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/150.query-block-name-qb-hint-of-oracle-mode.md).

Using this syntax allows you to specify a hint in the outer query that applies to an embedded view.

The syntax for the query block parameter is `@queryblock`, where `queryblock` is the identifier of the query block specified in the query. The `queryblock` identifier can be system-generated or user-defined. If you specify a hint directly within a query block, the `@queryblock` will be ignored.

* System-generated identifiers can be obtained by using `EXPLAIN` on the query.

* You can use QB_NAME to specify a user-defined name.

**Classification and feature of hints**


Hints in OceanBase Database are divided into two main types: global hints and query block hints.

Query block hints are further subdivided into QB_NAME hints, transform hints, and optimizer hints. Each type of hint has different classifications based on its feature within the optimizer.

**Global hints**


Global hints apply to the entire query and have the same effect regardless of their position in the query. For example, the parallel execution hints used in the following two queries are equivalent:

```sql
select /*+ parallel(8) */ * from ( select * from t1);
select * from ( select /*+ parallel(8) */ * from t1);
```


**Definition of global hints**


Global hints can target specific tables or indexes, or be more broadly applied to parts of tables or indexes within views. You can use `tablespec` and `indexspec` to define the target objects for global hints:

- `tablespec`: Defines the table that the global hint applies to. When using a hint, you must strictly follow the table name or alias as it appears in the query. If the query uses a table alias, the hint should also use the corresponding alias.

```sql
[ view.[, view. ]... ] table_name
```


  Note that even if the schema name is included in the query, it should not be included in the hint.

  > Notice: For queries that use ANSI joins, global hints specified with the `tablespec` clause are invalid because the optimizer generates additional views during parsing. In such cases, you should specify query block hints using `@queryblock`.

- `indexspec`: Defines the index that the global hint applies to. When specifying a hint, `indexspec` can follow `tablespec`, and separating the table name and index name with a comma is optional.

```sql
{ index
  | ( [ table. ] column_name [ [ table. ] column_name ]... )
  }
```


**Query block hints**


When the OceanBase optimizer parses a query, it divides the query into multiple query blocks based on its structure, with each query block having its own query block name. The query block name can be automatically generated by the optimizer or explicitly specified using the QB_NAME hint. For more information about query block names and the QB_NAME hint, such as how to use query block hints to specify the scope or target of a hint, see [Query block name and QB_NAME hint](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/150.query-block-name-qb-hint-of-oracle-mode.md).

For example, in the following query, the outer query block is named `qb1`, and the query block within the inline view `v` is named `qb2`:

```sql
select /*+ qb_name(qb1) */ * from ( select /*+ qb_name(qb2) */ * from t1 ) v;
```


A query block hint is only effective within the specific query block where it is defined. There are two ways to specify the effective scope of a query block hint:

- Directly add the hint to the specified query block.
- Specify the query block name in the hint, using the syntax `Hint_Name(@qb_name ...)`.

For example, in the following query, the `no_merge` hint is added directly to query block `qb2` and is effective within that block; the `index(@qb2 t1 idx)` hint is added to query block `qb1` and is made effective within query block `qb2` by specifying the query block name:

```sql
select /*+ index(@qb2 t1 idx) qb_name(qb1) */ *
from ( select /*+ no_merge qb_name(qb2) */ * from t1 ) v;
```


Within query block hints, apart from the QB_NAME hint which is used to specify the name of the current query block, other hints take effect at different stages of the optimizer: transform hints influence query rewrite behavior, while optimizer hints influence plan generation behavior.

Source: [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/100.hint-overview-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/100.hint-overview-of-oracle-mode.md)

## Appendix C: Query-block names and QB_NAME

When the OceanBase optimizer analyzes a query, it decomposes the query into multiple query blocks based on the query structure. Each block has a unique query block name (QB name). If not specified manually, the optimizer will automatically generate the QB name.

**Syntax and rules of the QB_NAME hint**


You can use the QB_NAME hint to explicitly assign a QB name to a query block. The syntax is as follows:

```sql
/*+ QB_NAME(qb_name) */
```


In the following example, the outer query block is named `qb1`, and the inline view (in the `view_1` view) is named `qb2`:

```sql
SELECT /*+ QB_NAME(qb1) */ * FROM (SELECT /*+ QB_NAME(qb2) */ * FROM t1) view_1;
```


**Considerations:**

- QB names are case-insensitive.
- A QB name cannot contain special characters.
- A QB name must be 20 characters or less in length.
- You cannot assign multiple QB names to the same query block or use the same QB name for different blocks.

**How to use query block name**


**Define the scope of query block hints**


Query block hints allow you to define the scope of a Hint by specifying a query block name within the Hint.

For example, the `index(@qb2 t1 idx)` hint is declared in the query block `qb1`, but takes effect in the query block `qb2`.

```sql
SELECT /*+ INDEX(@qb2 t1 idx) QB_NAME(qb1) */ * FROM (SELECT /*+ NO_MERGE QB_NAME(qb2) */ * FROM t1) view_1;
```


**Specify the objects to which hints apply in a query**


You can precisely control the objects to which a hint in a query applies.

You can specify the query block name in the hint to precisely specify the objects to which the hint applies.

For example, when you use the `leading` hint, the hint may be invalid if you do not specify the table name with the query block name.

```sql
SELECT /*+ LEADING(t1@sel$1 t1@sel$2) */ * FROM t1, (SELECT * FROM t1) v WHERE t1.c2 = v.c2;

Query Plan
```


**Automatic generation rules of query block name**


If you do not specify a QB name, the optimizer automatically generates a QB name in the following format:

```sql
query_block_type_str$idx
```


In this format, `query_block_type_str$` is a string that identifies the query block type, and `idx` is the serial number that identifies the query block.

The following table shows examples of automatically generated names for different types of query blocks.

| Query block    | Example      |
|----------|----------|
| SELECT   | SEL$1    |
| UNION ALL/UNION/INTERSECT/MINUS | SET$1    |
| INSERT   | INS$1    |
| UPDATE   | UPD$1    |
| DELETE   | DEL$1    |
| MERGE    | MRG$1 |
| REPLACE | REP$1 |
| INSERT ALL | INS_ALL$1 |

For example, the optimizer automatically generates a query block name for a query block that contains the `UNION` operator. For example, in a query that contains the `UNION` operator, the query block is automatically named `SET$1`.

```sql
SELECT /*+ USE_HASH_SET(@SET$1) */ c1, c2 FROM t1
UNION
SELECT c1, c2 FROM t2;
```


In this example, the hint `/*+USE_HASH_SET(@SET$1) */` instructs the optimizer to use the `HASH DISTINCT SET` algorithm for the `UNION` operation.

**Query block name in complex queries**


When parsing more complex queries, the optimizer assigns an incremental serial number to each query block in an inner-to-outer order. If you remove the manually specified QB_NAME hint, the automatically generated query block names will be as follows:

```sql
SELECT /*+ QB_NAME(qb1) */ * FROM (SELECT /*+ QB_NAME(qb2) */ * FROM t1) v;
```


After you remove the QB_NAME hint, the automatically generated name of the outer query block `qb1` will be `SEL$1`, and the name of the inner query block `qb2` will be `SEL$2`.

**Query rewrite and changes of query block name**


When a query block is involved in query rewrite, its query block name can be changed. You can use the `EXPLAIN EXTENDED` statement to track these changes in the `qb name trace` section of the query plan.

To confirm the automatically generated query block name before query rewrite, you can add the `NO_QUERY_TRANSFORMATION` hint to the query to disable all query rewrites, and then use the `EXPLAIN OUTLINE` statement to obtain the OUTLINE DATA. By analyzing the Query Block Hints such as `FULL`, `INDEX`, and `LEADING` in the OUTLINE DATA, you can verify the name of each query block.

For example, in the following query, the `FULL(@"SEL$2" "test"."t1"@"SEL$2")` in the OUTLINE DATA indicates that the query block name in the inline view `v` is `SEL$2`:

```sql
SELECT /*+ NO_QUERY_TRANSFORMATION */ COUNT(*)
FROM (SELECT * FROM t1) v GROUP BY c1;
```

Source: [en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/150.query-block-name-qb-hint-of-oracle-mode.md](https://github.com/oceanbase/oceanbase-doc/blob/017c8d35a015afa04ce1e1ce4b95675e3223c878/en-US/700.reference/500.sql-reference/100.sql-syntax/300.common-tenant-of-oracle-mode/300.basic-elements-of-oracle-mode/600.annotation-of-oracle-mode/400.hint-of-oracle-mode/150.query-block-name-qb-hint-of-oracle-mode.md)

## Appendix D: Reviewed tokens not counted as independent hints

| Token | Classification |
|---|---|
| `BEGIN_OUTLINE_DATA` | Outline-data structural marker; covered separately, not counted as an independent optimizer hint. |
| `HAHA` | Placeholder or generic grammar text, not a concrete hint name. |
| `HINT1` | Placeholder or generic grammar text, not a concrete hint name. |
| `HINT2` | Placeholder or generic grammar text, not a concrete hint name. |
| `HINT3` | Placeholder or generic grammar text, not a concrete hint name. |
| `HINT_TEXT` | Placeholder or generic grammar text, not a concrete hint name. |
| `INSERT` | Placeholder or generic grammar text, not a concrete hint name. |
| `KAKA` | Placeholder or generic grammar text, not a concrete hint name. |
| `PARALELL` | Spelling occurs in vector-index DDL examples, outside query-hint scope; not treated as a separate query hint. |
| `XXX` | Placeholder or generic grammar text, not a concrete hint name. |

`SQL_CACHE`, `SQL_NO_CACHE`, `SQL_CALC_FOUND_ROWS`, and `STRAIGHT_JOIN` are MySQL `SELECT` options/clauses, not `/*+ ... */` query hints, and are therefore outside this hint-name inventory.

## Appendix E: Coverage and audit method

1. Recursively read all 18 pages in the dedicated Oracle-mode hint chapter.
2. Extracted 137 hint sections and consolidated them into 134 unique names, retaining duplicate source sections.
3. Scanned 1172 SQL Reference pages for `/*+ NAME` usage and reviewed MySQL statement pages separately.
4. Cross-scanned 5995 English documentation pages to identify additional evidence and placeholders.
5. Merged the shared optimizer-guide sections, added `UNION_MERGE`, and curated `TRACE_LOG` and `JOIN_ORDER` from their official examples.
6. Preserved source syntax, parameters, behavior, considerations, and examples; removed client prompts and result grids. No unsupported hint was imported from generic Oracle or MySQL documentation.
7. The machine-readable coverage manifest is stored at `verifier/v1/coverage-manifest.json`.
