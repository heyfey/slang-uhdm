// § ifaceArrPortElemViewNamedByArray200
interface bif(input bit clk);
  logic [3:0] d;
  modport MP(input clk, output d);
endinterface
module leaf(bif.MP q[1:0]);
  assign q[0].d = 4'h1;
endmodule
program pr(bif.MP p[1:0]);
  initial $display(p[1].d);
endprogram
module top; bit clk; bif ba[1:0](clk); pr P(ba); leaf L(ba); endmodule
