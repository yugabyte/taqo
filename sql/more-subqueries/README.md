# more-subqueries

This model contains queries with various types of subqueries and aims to cover most, if not all, of the representative subquery execution patterns.

# Types of Subqueries

## Subquery Table Expressions (Inline Views)

Subquery table expressions can appear in the FROM clause and semantically treated in the same way as other table expressions such as base table, user-defined view, table function, etc.

 * Regular inline view - no outer column references allowed
 * Recursive CTE (Common Table Expression) - the intermediate results from the recursive UNION branch are inserted into a temporary table at each recursion
 * LATERAL subquery - The LATERAL keyword makes the inline view subquery allow referencing tables outside of the subquery, the preceding tables in the FROM clause.

They are joined together with other table expressions in the FROM clause according to the specified join type.

The outer references in a LATERAL subquery disables materialization, sort merge join and hash join if the optimizer doesn't pull them out from the subquery.

## Subquery Boolean Expressions

Subquery Boolean expressions are typically used in the WHERE/ON/HAVING clause, however, can appear anywhere scalar expression can be used. e.g. SELECT-list.

 * EXISTS/NOT EXISTS
 * IN/NOT IN
 * {=,<>,<,<=,>,>=} {ANY|ALL} (Quantified Predicates)

These expressions are converted to a semijoin (EXISTS, IN, ANY), antijoin (NOT EXISTS) or an inner join when the optimizer can do so. Otherwise, Postgres creates a SubPlan (materialized via hash SubPlan if there's no outer reference).

## Other Subquery Expressions

The subquery expressions can appear elsewhere in place of scalar, row value or array expression.

  * Scalar subquery expression
  * Single Row subquery expression
  * Array subquery expression

Postgres creates an InitPlan (if there's no outer reference) or a SubPlan.
