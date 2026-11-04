// § ppFileCallArgBody168
`include "msg.svh"
// the outer macro defined in the include too; a function call (no handle) in the nested actual
`define TRACE2(ID) \
   `info(ID, {"a", \
       get_full_name()}, 1);
class ph;
  function string get_full_name(); return "x"; endfunction
  function int en(int v, string s); return 1; endfunction
  function void rpt(string a, string b, int c, string d, int e); endfunction
  function void run();
    `TRACE2("PH")
  endfunction
endclass
module top;
  ph p = new;
endmodule
