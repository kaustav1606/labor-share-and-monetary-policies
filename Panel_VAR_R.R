


### Panel VAR
ex1_feols <-pvarfeols(dependent_vars = c("lab_inc_sh_va", "lab_prod", "price_index","l_k._ratio","wacr","fiscal"),
                      lags = 1,
                      transformation = "demean",
                      data = data_panel,
                      panel_identifier= c("industry", "time"))

ex1_hk <-
  pvarhk(dependent_vars = c("lab_inc_sh_va", "lab_prod", "price_index","l_k._ratio","fiscal","wacr"),
         transformation = "demean",
         data = data_panel,
         panel_identifier= c("industry", "time"))

### IRF functions 
girf(ex1_feols, n.ahead = 20, ma_approx_steps= 8)




gmm_labsh <- pvargmm(dependent_vars = c("lab_inc_sh_va", "lab_prod", "price_index","l_k._ratio","fiscal","wacr"),
                     lags = 2,
                     transformation = "fod",
                     data = data_panel,
                     panel_identifier=c("industry", "time"),
                     steps = c("twostep"),
                     system_instruments = FALSE,
                     collapse = FALSE
)











