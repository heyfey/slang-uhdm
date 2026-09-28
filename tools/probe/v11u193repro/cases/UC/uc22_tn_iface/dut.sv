// § caUnsizedRhsClonePerInst193
interface ifc #(parameter bit P = 1);
  logic [7:0] x;
  logic [7:0] y;
  assign y[3:0] = (P) ? x[3:0] : '0;
endinterface
module top (output logic [7:0] y);
  ifc #(.P(0)) i_a ();
  assign y = i_a.y;
endmodule
