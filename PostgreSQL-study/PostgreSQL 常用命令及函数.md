select txid_current();
select txid_current_snapshot();

select pg_backend_pid();

begin;
lock table t1;
xxx
end;

select oid, * from pg_class where relname='t1';