with deduped as(
select *,
row_number() over(partition by game_id,team_id,player_id) as rn
from game_details
)
select * from deduped
where rn=1