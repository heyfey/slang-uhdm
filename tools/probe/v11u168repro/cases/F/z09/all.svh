// the reporting macro, as uvm_message_defines.svh writes it
`define info(ID, MSG, VERBOSITY) \
   begin \
     if (en(VERBOSITY,ID)) \
       rpt (ID, MSG, VERBOSITY, "", 1); \
   end
`define TRACE(ID,MSG,PH,VERB) \
   `info(ID, {$sformatf("Phase '%0s' (id=%0d) ", \
       PH.get_full_name(), PH.get_inst_id()),MSG}, VERB);
`define TOP(P) \
   `TRACE("A","B",P,1)
