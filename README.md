#### rbspider

rbspider is a web scrawler based on rpsider, here are some of its advantage:
* easy to customize your owner parser
* easy to config your crawler job
* easy to save to your data since rbspider take advantage of Activerecord

#### how rbspider works

rbspider is not only a spider crawl the links, rbspider is a mini framework to get content from some specific website, so rbspider is consisted of a crawl engine, parse engine, database engine. 

* crawl engine

  our crawl is totally based on spidr.
  Spidr is a versatile Ruby web spidering library that can spider a site, multiple domains, certain links or infinitely. Spidr is designed to be fast and easy to use.

* parse engine

  we are using Nokogiri as the content parse engine, so the most work when we are start using rbspider is to implement a parse engine for your specific website.

* database engine

  we are using Activerecord to manipulate the data.

#### how to start

we have already implemented some parser for some websites already, so you can just type:

```
 $ ruby run.rb -c config.json
```

if you want crawl a website, you need to implement a parse class (Ruby) inherited from ParserEngine, then implement a result class (Ruby) inherited from ParsersResult.  then update the config.json, yeah, that is it, you can just type:

```
  $ ruby run.rb -c config.json
```

all the data will save to sqlite db file.
