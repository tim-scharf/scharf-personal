buildLogs <- function(){


feat_cols <- names(L_wide)[2:387]
L_wide[,e:= apply(.SD,1,entropy),.SDcols=feat_cols]
L_wide[,tot_logs := rowSums(.SD),.SDcols=feat_cols]
L_wide[,max_logs:= apply(.SD,1,max),.SDcols=feat_cols]
L_wide[,min_logs:= apply(.SD,1,function(row)min(row[row>0])    ),.SDcols=feat_cols]
