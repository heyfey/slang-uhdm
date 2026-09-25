// § ppFileCallArgBody168
`define info(ID, MSG, VERBOSITY) \
   begin \
     if (en(VERBOSITY,ID)) \
       rpt (ID, MSG, VERBOSITY, "", 1); \
   end
`include "trace.svh"
class ph;
  function string get_full_name(); return "x"; endfunction
  function int get_inst_id(); return 1; endfunction
  function int en(int v, string s); return 1; endfunction
  function void rpt(string a, string b, int c, string d, int e); endfunction
  function void run();
    if (1) begin
      `TRACE("PH/TRC","Starting phase",this,1)
    end
  endfunction
endclass
module top;
  ph p = new;
endmodule
