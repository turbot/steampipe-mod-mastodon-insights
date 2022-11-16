create or replace function toots(timeline text, max int) 
  returns table (
    connection text,
    person text,
    created text,
    is_boost text,
    url text,
    in_reply_to text,
    toot text
  ) as $$
  declare sql text := '
    with toots as (
      select
        _ctx ->> ''connection_name'',
        user_name || ''.'' || display_name,
        to_char(created_at, ''MM-DD HH24:MI'') as created_at,
        case 
          when reblog -> ''url'' is not null then ''yes''
          else ''''
        end,
        case
          when reblog -> ''url'' is not null then reblog ->> ''url''
          else url
        end,
        case
          when in_reply_to_account_id is not null then  ( select acct from mastodon_account where id = in_reply_to_account_id )
          else ''''
        end as in_reply_to,
        case
          when reblog -> ''url'' is null then
            sanitize_toot(content)
          else
            sanitize_toot(reblog ->> ''content'')
        end as toot
      from   
        %I
      limit
        $1
    )
    select
      *
    from
      toots
    order by 
      created_at desc
  ';
begin
  return query execute format (sql, timeline) using max;
end;
$$ language plpgsql;

create or replace function sanitize_toot(toot text) returns text as $$
  declare 
    untagged text := regexp_replace(toot, '<[^>]+>', '', 'g');
    unapostrophized text := replace(untagged, '&#39;', '');
    unquoted text := replace(unapostrophized, '&quot;', '');
  begin
    return unquoted;
  end;
$$ language plpgsql;
