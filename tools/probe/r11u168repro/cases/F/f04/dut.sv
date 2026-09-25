// § ppFileCallArgBody168
`include "msg.svh"
// a multi-line actual holding the call, directly to the multi-line macro
class ph;
  function string get_full_name(); return "x"; endfunction
  function int en(int v, string s); return 1; endfunction
  function void rpt(string a, string b, int c, string d, int e); endfunction
  function void run();
    `info("PH", $sformatf("%s %0d",
                          get_full_name(),
                          3), 1)
  endfunction
endclass
module top;
  ph p = new;
endmodule
