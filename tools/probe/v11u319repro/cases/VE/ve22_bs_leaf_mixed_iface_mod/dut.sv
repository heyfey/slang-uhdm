// § ifaceConnSelWholeLeafElab319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  logic o2;
  ifc u (.clk(ck[1+s]));
  child c (.d(ck[1+s]), .q(o2));
  assign o = u.sig[0] ^ o2;
endmodule
