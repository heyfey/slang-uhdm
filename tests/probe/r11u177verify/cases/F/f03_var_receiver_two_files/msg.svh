`define info(ID, MSG, VERBOSITY) \
   begin \
     if (en(VERBOSITY,ID)) \
       rpt (ID, MSG, VERBOSITY, "", 1); \
   end
