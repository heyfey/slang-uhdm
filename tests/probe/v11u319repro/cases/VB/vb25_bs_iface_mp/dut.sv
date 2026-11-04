// § ifaceConnSelWholeLeafElab319
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input clk);
endinterface
module user (ifc.mp p, output logic y);
  assign y = p.clk;
endmodule
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  ifc u (.clk(ck[1+s]));
  user us (.p(u.mp), .y(o));
endmodule
