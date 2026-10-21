// § ifcProcCallArgNoTs424
interface ifc(input bit clk);
  int x;
  function automatic int g(int v); return v * 2; endfunction
  initial x = g(3);
  always_comb if (g(x) > 4) $display("big");
endinterface
module top;
  bit c;
  ifc d(.clk(c));
endmodule
