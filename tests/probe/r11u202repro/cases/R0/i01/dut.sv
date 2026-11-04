// § ifaceArrPortElemViewNamedByArray200
interface bif(input bit clk);
  logic [3:0] d;
  logic v;
  modport MP(input clk, input d, output v);
endinterface
program pr(bif.MP p[3], input bit x);
  initial $display(p[2].d, x);
endprogram
module top; bit clk; bif ba[3](clk); pr P(.p(ba), .x(clk)); endmodule
