-- No extended statistics anywhere in this model, on purpose.
--
-- A statistics object on (c7, c8) would teach the estimator that the two
-- columns are identical and remove the misestimate that the impossible-twin
-- queries in merge-07 exist to exercise.  Objects on the bucket column would
-- likewise mask how the derived and user-written forms of the same condition
-- are estimated differently (yugabyte/yugabyte-db#33251).  The model's job is
-- to measure the cost model on the estimates a plain ANALYZE produces, so
-- that is all it takes.

analyze mb2;
analyze mb4;
analyze mb16;
analyze mb64;
analyze mplain;
analyze mn16;
analyze mw16;
analyze ms16;
analyze sel;
analyze sa;
analyze dj;
analyze de16;
analyze de2c;
analyze dex;
analyze riv;
analyze rivb;

analyze pt_p1;
analyze pt_p2;
analyze pt_p3;
analyze pt_p4;
analyze pt;
