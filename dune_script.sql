with cp as (select date_trunc('day', evt_block_time) as day, min(value/1e18) as floor_price_in_eth, AVG(value/1e18) as avg_price_in_eth
from cryptopunks."CryptoPunksMarket_evt_PunkBought"
where value > 0 and value < 20000*1e18
group by 1
order by 1 desc
limit 180
),

  eth as (select date_trunc('day', minute) as day, AVG(price) as eth_average
    from prices.layer1_usd
    where "symbol" = 'ETH'
    GROUP BY 1
    ORDER BY day DESC
    limit 180
)

select cp.day, cp.floor_price_in_eth, cp.avg_price_in_eth, (cp.avg_price_in_eth)*(eth.eth_average) as cp_avg_price_in_usd, eth.eth_average,
((eth.eth_average - LAG(eth.eth_average, 1) OVER (order by eth.day))/LAG(eth.eth_average, 1) OVER (order by eth.day))*100 as pct_change_eth 
from cp
join eth
on cp.day=eth.day
order by 1 desc
limit 180
