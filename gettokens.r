library(amcatr)
c = amcat.connect("http://preview.amcat.nl")
tokens = amcat.gettokens(c, 1006, 25173, module = "morphosyntactic", page_size = 10, only_cached = T)
save(tokens, file="tmp/tokens.rda")