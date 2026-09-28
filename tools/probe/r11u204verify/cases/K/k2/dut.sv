// § genCaCastRhsRefUnnamed198: nested casts (a size cast of a size cast, a typedef cast of a signed cast, unsigned of a size cast: v11u198's residue 3 faces)
module top (input logic s, input logic [2:0] q [2], output logic [2:0] y [2], output logic [2:0] z [2], output logic [2:0] w [2]);
  typedef logic [2:0] t3;
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = 3'(4'(s));
    assign z[i] = t3'(signed'(q[i]));
    assign w[i] = unsigned'(3'(q[i]));
  end
endmodule
