library(amcatr)
library(rsyntax)
conn = amcat.connect("http://preview.amcat.nl")

tokens = amcat.gettokens(conn, 1006, 25173, module = "morphosyntactic", page_size = 100, only_cached = T)
tokens$id = as.numeric(gsub('.*_', '', tokens$term_id))
tokens$parent = as.numeric(gsub('.*_', '', tokens$parent))

## sort and make ids global
tokens = tokens[order(tokens$aid, tokens$id),]
tokens = unique_ids(tokens)

saveRDS(tokens, file="data/tokens_oekraine.rds")

## tot hier uitvoeren!!!

head(tokens)

# let's plot one! :)
library(rsyntax)
g = rsyntax::graph_from_sentence(tokens, sentence = 1)
plot(g)
