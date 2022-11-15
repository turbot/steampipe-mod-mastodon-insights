create or replace function sanitize_toot(toot text) returns text as $$
  select
    replace (
      replace (
      regexp_replace(toot, '<[^>]+>', '', 'g'),
      '&#39;', 
      ''''
      ),
      '&quot;', 
      '"'
    )
$$ language sql
  