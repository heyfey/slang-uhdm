// § ifaceConnLeftmostLeafElab315
interface ifw (input logic [3:0] clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, input logic [1:0] b, output logic o);
  ifw u (.clk(-{a, b}));
  assign o = u.sig[0];
endmodule
