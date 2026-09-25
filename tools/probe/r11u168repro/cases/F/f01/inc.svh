// the define lives in an include file
`define rep(ID, MSG) \
   begin \
     if (en(ID)) \
       rpt (ID, MSG, 1); \
   end
