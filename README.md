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
