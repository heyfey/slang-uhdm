// r10v105 v3 — the clone arm carries NO `cvL9.isInteger() && !hasUnknown()`
// guard, which the decimal mint it preempts DOES carry.  A parameter whose
// elaborated value is UNKNOWN or NOT an integer therefore reaches the copy on
// the patched binary where pristine fell through to a `ref_obj`.
module v3_leaf105 #(
  parameter logic signed [7:0] X = 8'b1010_z01x,
  parameter int                N = 4
) (input logic [31:0] sig, output logic [63:0] z);
  localparam logic signed [7:0] U = 8'b11xx_0z01;
  localparam int signed         S = -1;
  localparam real               R = 1.5;
  localparam string             T = "ab";
  for (genvar i = 0; i < 2; i++) begin : gen_u
    logic [63:0] w0,w1,w2,w3;
    assign w0 = X ^ sig;
    assign w1 = U ^ sig;
    assign w2 = S ^ sig;
    assign w3 = N ^ sig;
  end
  assign z = 64'b0;
endmodule

module v3_unk105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  v3_leaf105 #(.X(8'b1010_z01x), .N(4)) u_leaf (.sig(sig), .z(zc));
  assign z = zc;
endmodule
