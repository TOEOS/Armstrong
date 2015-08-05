# Armstrong
IDEAS Hackathon 2015

##pre-requirement
jieba lib (python) - `pip install jieba`

## Start server
jieba library
- Start jieba bridge - `rake jieba:start`

Background worker
- Start sidekiq - `sidekiq -C config/sidekiq.yml`
- Start redis - `redis-server`
- Setup cron jobs - `whenever -w`

Web socket push server
- Reference another project: [apollo-radio](https://github.com/TOEOS/Apollo-radio)

## Collaborators

- Tim ([@Tim-Feng](https://github.com/Tim-Feng))
- Orga ([@sinorga](https://github.com/sinorga))
- Sunkai ([@sunkai612](https://github.com/sunkai612))
- Otis ([@AnNOtis](https://github.com/AnNOtis))
- Emma
- Puff ([@puff-tw](https://github.com/puff-tw))
