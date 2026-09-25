// § ppFileCallArgBody168
`include "inc.svh"
module top;
  function int en(string s); return 1; endfunction
  function void rpt(string a, string b, int c); endfunction
  function string nm(); return "x"; endfunction
  initial `rep("A", $sformatf("%s", nm()))
endmodule
