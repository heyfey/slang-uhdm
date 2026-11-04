// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
  function automatic int f(string s, int n); return s.len() + n; endfunction
  int r, a;
  initial r = f(.s(`VS), .n(a + 1));
endmodule
