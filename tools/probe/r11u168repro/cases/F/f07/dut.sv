// § ppFileCallArgBody168
`include "msg.svh"
// an inactive branch inside the outer body before the nested call
`define TRACE(ID,PH) \
`ifdef NOPE \
   x = 1; \
`endif \
   `info(ID, {"a", \
       PH.get_full_name()}, 1);
class ph;
  function string get_full_name(); return "x"; endfunction
  function int en(int v, string s); return 1; endfunction
  function void rpt(string a, string b, int c, string d, int e); endfunction
  function void run();
    `TRACE("PH",this)
  endfunction
endclass
module top;
  ph p = new;
endmodule
