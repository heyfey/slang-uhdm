// § ppFileCallArgBody168
`include "msg.svh"
// the call is the OUTER macro's actual, passed on to the nested call
`define TRACE(ID,MSG,VERB) \
   `info(ID, MSG, \
       VERB);
class ph;
  function string get_full_name(); return "x"; endfunction
  function int en(int v, string s); return 1; endfunction
  function void rpt(string a, string b, int c, string d, int e); endfunction
  function void run();
    `TRACE("PH", $sformatf("%s", get_full_name()), 1)
  endfunction
endclass
module top;
  ph p = new;
endmodule
