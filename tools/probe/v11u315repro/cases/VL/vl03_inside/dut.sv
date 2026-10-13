// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, input logic [1:0] b, input logic [1:0] c, output logic o);
  ifc u (.clk(a inside {b, c}));
  assign o = u.sig[0];
endmodule
