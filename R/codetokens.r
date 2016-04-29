library(rsyntax)
library(tokenlist)
source('R/lib.r')

### load tokens (use gettokens.r to prepare tokens file)
tokens = readRDS('data/tokens_oekraine.rds')

### add clauses
quotes = get_quotes_nl(tokens)
clauses = get_clauses_nl(tokens, quotes)
tokens = tokenClauseAnnotation(tokens, clauses)

head(tokens,10)

saveRDS(tokens, file='data/prepared_tokens_oekraine.rds')

############# add codes (codebook)
tokens = readRDS('data/prepared_tokens_oekraine.rds')

### prepare codebook
cb = read.csv('codebooks/VD_04-29_ jk OekOntologie.csv')
cb = prepareCodebook(cb)

# adhoc schoonmaak
#cb$indicator = as.character(cb$indicator)
#cb$indicator[cb$code == 'positief'] = gsub('*', '* ', cb$indicator[cb$code == 'positief'], fixed=T)
#cb$indicator[cb$code == 'negatief'] = gsub('*', '* ', cb$indicator[cb$code == 'negatief'], fixed=T)

cb = cb[!is.na(cb$parent),]
cb = cb[!cb$parent == 'ideaal',]

## fix excel's special character booboos
cb$indicator = gsub('+AH4-', '~', cb$indicator, fixed=T)
cb$condition = gsub('+AH4-', '~', cb$condition, fixed=T)
cb$indicator = gsub('+ACo-', '*', cb$indicator, fixed=T)
cb$condition = gsub('+ACo-', '*', cb$condition, fixed=T)
cb$indicator = gsub('+ACoAfg--', '*~', cb$indicator, fixed=T)
cb$condition = gsub('+ACoAfg-', '*~', cb$condition, fixed=T)


### code tokens
# first change colnames of tokens to work with codeTokens()
colnames(tokens)[colnames(tokens) == 'aid'] = 'doc_id'
colnames(tokens)[colnames(tokens) == 'id'] = 'position'

queries = data.frame(code = cb$code, 
                     indicator=cb$indicator, 
                     condition=cb$condition)
queries = queries[!queries$indicator == '',]
queries = queries[!is.na(queries$indicator),]

## apparently codeTokens takes up too much memory with long queries and too many tokens, therefore iterate through batches
doc_ids = unique(tokens$doc_id)
batches = split(doc_ids, ceiling(seq_along(doc_ids)/100)) # batches of 10

tokens$concept = ''
for(i in 1:length(batches)){
  print(sprintf('%s / %s', i, length(batches)))
  selection = tokens$doc_id %in% batches[[i]]
  tokens$concept[selection] = codeTokens(tokens[selection,], queries, text_var = 'word', verbose = F)
}
print(queries$condition)

saveRDS(tokens, file='data/prepared_tokens_oekraine.rds')

## todo: think of more efficient way to deal with long lists of indicators.
## Currently indicators are also used in the query matrix, which is usefull for 'recycling' indicators across queries.
## However, its probably more efficient to just look up indicators as grep indicator1|indicator2|etc. 

### try without sentiment