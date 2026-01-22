do $$
begin
  perform
    n.nspname,
    c.relname,
    yb_index_check(c.oid)
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.relkind = 'i'
    and n.nspname not in ('pg_catalog', 'information_schema');
exception when others then
  null;
end;
$$;
