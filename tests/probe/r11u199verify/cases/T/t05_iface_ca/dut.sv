// § caTernFillArmKept193
interface ifc #(parameter bit P = 1) (input logic [7:0] x);
  logic [7:0] y [2];
  assign y[0] = (P) ? '1 : x + 8'd1;
  assign y[1] = x;
endinterface
module top (input logic [7:0] x, output logic [7:0] a, output logic [7:0] b);
  ifc #(.P(0)) i_a (.x(x));
  ifc #(.P(1)) i_b (.x(x));
  assign a = i_a.y[0];
  assign b = i_b.y[0];
endmodule
