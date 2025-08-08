with recursive cte(id, parent_id, v, depth, path) as (
  select id, parent_id, v, 0, '' from t3 as t where id = 0
  union all
  select t3.id, t3.parent_id, t3.v, depth + 1, path||lpad(t3.id::text, 6, '-')
    from t3 join cte on t3.parent_id = cte.id
)
select parent_id, id, lpad(' ', depth * 2)||v from cte order by path;
