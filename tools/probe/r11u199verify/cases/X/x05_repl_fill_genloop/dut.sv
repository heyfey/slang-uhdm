// § genForReplCountOwner192 § caTernFillArmKept193 § caUnsizedRhsClonePerInst193
package p;
  parameter int unsigned R = 4;
endpackage
module m import p::*; #(parameter bit P = 1) (input logic [7:0] x, output logic [7:0] y [2], output logic [7:0] z [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = (P) ? {R{2'b01}} : '1;
    assign z[i] = (P) ? '0 : {{R{1'b0}}, x[3:0]};
  end
endmodule
module top (input logic [7:0] x, output logic [7:0] a [2], output logic [7:0] b [2], output logic [7:0] c [2], output logic [7:0] d [2]);
  m #(.P(0)) u_a (.x(x), .y(a), .z(b));
  m #(.P(1)) u_b (.x(x), .y(c), .z(d));
endmodule
