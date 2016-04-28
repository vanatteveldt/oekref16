prepareCodebook <- function(cb, code_columns=NULL){
  if(is.null(code_columns)) code_columns = colnames(cb)[grep('[0-9]+', colnames(cb))]
  if(!'code_id' %in% colnames(cb)) cb$code_id = 1:nrow(cb)
  
  code_columns = code_columns[code_columns %in% colnames(cb)]
  code = cb[,code_columns]
  code[is.na(code)] = ''
  
  cb = data.frame(code_id = cb$code_id,
                  code = as.character(apply(code, 1, paste, collapse='')),
                  level = apply(code, 1, function(x) min(which(!x == ''))), # first column with text
                  indicator = as.character(cb$indicator),
                  condition = as.character(cb$condition))
  
  cb$parent_id = NA
  parents = NA
  for(i in 1:nrow(cb)){
    j = cb$level[i]
    parents[j] = cb$code_id[i]
    cb$parent_id[i] = ifelse(j > 1, parents[j-1], NA)
  }
  cb$parent = cb$code[match(cb$parent_id, cb$code_id)]
  cb
}

