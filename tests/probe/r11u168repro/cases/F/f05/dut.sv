// § ppFileCallArgBody168
`include "msg.svh"
// a pasted name in the nested body's actual
`define TRACE(ID,PFX,PH) \
   `info(ID, {"a", \
       PH.get_``PFX``_name()}, 1);
class ph;
  function string get_full_name(); return "x"; endfunction
  function int en(int v, string s); return 1; endfunction
  function void rpt(string a, string b, int c, string d, int e); endfunction
  function void run();
    `TRACE("PH",full,this)
  endfunction
endclass
module top;
  ph p = new;
endmodule
