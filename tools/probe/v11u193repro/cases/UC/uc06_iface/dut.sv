// § caUnsizedRhsClonePerInst193
interface ifc;
  logic c;
  logic [3:0] d;
  assign d[1:0] = c ? 2'b1 : '0;
endinterface
module top (input logic c, output logic [3:0] y);
  ifc i_a ();
  assign i_a.c = c;
  assign y = i_a.d;
endmodule
