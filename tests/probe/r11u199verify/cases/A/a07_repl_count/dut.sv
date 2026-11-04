// § genForReplCountOwner192 § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned R = 3;
endpackage
module sub import p::*; (input logic [31:0] x, output logic [31:0] y [2], output logic [31:0] z, output logic [31:0] w [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = {{R{x[i]}}, x[31-R:0]};
    assign w[i] = {{(R+1){1'b1}}, x[30-R:0]};
  end
  for (genvar k = 0; k < 1; k++) begin : h
    assign z = {{R{1'b0}}, x[31-R:0]};
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] y [2], output logic [31:0] z, output logic [31:0] w [2]);
  sub u (.*);
endmodule
