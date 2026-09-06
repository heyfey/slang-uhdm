// r10v105 v9 — INSTANCE DEPTH 3 and an INTERFACE home.  The law claims the
// instance's DEPTH does not enter the question; a grandchild's top-level
// loop-generate body must fold exactly like a child's, and an INTERFACE
// instance must behave like a module instance.
interface v9_if105 #(parameter int IFP = 3) (input logic [31:0] sig);
  localparam logic [3:0] IFR = {2{2'b01}};
  logic [63:0] iz;
  for (genvar i = 0; i < 2; i++) begin : gen_if
    logic [63:0] u0, u1;
    assign u0 = IFP ^ sig;
    assign u1 = IFR ^ sig;
  end
  assign iz = 64'b0;
endinterface

module v9_g2105 (input logic [31:0] sig, output logic [63:0] z);
  localparam int         G2I = 7;
  localparam logic [3:0] G2R = {4{1'b1}};
  for (genvar i = 0; i < 2; i++) begin : gen_g2
    logic [63:0] v0, v1, v2;
    assign v0 = G2I ^ sig;
    assign v1 = G2R ^ sig;
    assign v2 = sig[G2R];
  end
  assign z = 64'b0;
endmodule

module v9_g1105 (input logic [31:0] sig, output logic [63:0] z);
  localparam int G1I = 5;
  logic [63:0] zg;
  v9_g2105 u_g2 (.sig(sig), .z(zg));
  for (genvar i = 0; i < 2; i++) begin : gen_g1
    logic [63:0] w0;
    assign w0 = G1I ^ sig;
  end
  assign z = zg;
endmodule

module v9_depth105 (input logic [31:0] sig, output logic [63:0] z);
  localparam int TOPI = 9;
  logic [63:0] zc;
  v9_g1105 u_g1 (.sig(sig), .z(zc));
  v9_if105 #(.IFP(3)) u_if (.sig(sig));
  for (genvar i = 0; i < 2; i++) begin : gen_top
    logic [63:0] x0;
    assign x0 = TOPI ^ sig;
  end
  assign z = zc;
endmodule
