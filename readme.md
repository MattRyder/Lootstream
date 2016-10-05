## Lootstream
*An (unfinished) web application for placing bets on e-sports / Twitch streams*

["Working" Demo on Heroku](https://lootstream.herokuapp.com)

![A screenshot of Lootstream](https://s22.postimg.org/xu1as8bch/CAo_SSCz_WMAEn_Jy_M.png)
*A screenshot of Lootstream's "Popular Channels" page, and a list of the most popular games being played*

### Installation

* Clone via Github
* Bundle, Migrate and boot the Rails server
* Setup a connection in Twitch's Settings area, set the redirect_url to your host
* Set the `twitch_client_id` and `twitch_client_key` in config/secrets.yml (the ones there have been scrapped!)

# So why are you not working on this anymore?
Difficulty with monetisation and development fatigue were a large part, then [the CSGO Lotto fiasco](http://www.bbc.co.uk/news/technology-36702905) happened and it became clear that Lootstream isn't a project that would be workable in today's market.

Most of the e-sports market audience are under 18, and therefore difficult to financially convert, doubly so if the Gambling Commission get involved and decide to shut down the site on a whim. And [quite frankly...](https://youtu.be/zGxwbhkDjZM?t=24s)