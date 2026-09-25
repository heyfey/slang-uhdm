// § ppFileCallArgBody168
`include "msg.svh"
// the nested call's actual on ONE line (the call stays on the body's first output line)
`define TRACE(ID,PH) \
   `info(ID, {"a", PH.get_full_name()}, 1);
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
