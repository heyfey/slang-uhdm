// r10earl70 arm 1 — MEASUREMENT ONLY.  A port-actual select BOUND read of a
// symbol of each ORIGIN, in a module-body home and in a gen-for home, over
// every select position, against the cont_assign control at the same home.
package pa_earl70;
  localparam int ALP = 16;
  parameter  int APR = 16;
endpackage

package pb_earl70;
  parameter  int BPR = pa_earl70::ALP;
  localparam int BLP = pa_earl70::ALP;
  parameter  int BQ  = 1;
  typedef enum logic [31:0] { BE0 = 32'd16 } be_t;
endpackage

module lf_earl70 (
  input [31:0] p0, input [31:0] p1, input [31:0] p2, input p3,
  input [31:0] p4, input [31:0] p5, input [31:0] p6);
endmodule

module m1_earl70 import pa_earl70::*; import pb_earl70::*; (
  input [31:0] sig, output logic [31:0] o0, output logic [31:0] o1);
  parameter  int MPR = 16;
  localparam int MLP = 16;

  // ---- ALP : module-body home
  lf_earl70 i_mod_ALP (
      .p0(sig[ALP-1:BQ]),
      .p1(sig[0 +: ALP]),
      .p2(sig[ALP +: 4]),
      .p3(sig[ALP]),
      .p4(sig[ALP-1:0]),
      .p5(sig[31:ALP]),
      .p6(ALP)
  );
  logic [31:0] c_ALP; assign c_ALP = sig[ALP-1:BQ];

  // ---- APR : module-body home
  lf_earl70 i_mod_APR (
      .p0(sig[APR-1:BQ]),
      .p1(sig[0 +: APR]),
      .p2(sig[APR +: 4]),
      .p3(sig[APR]),
      .p4(sig[APR-1:0]),
      .p5(sig[31:APR]),
      .p6(APR)
  );
  logic [31:0] c_APR; assign c_APR = sig[APR-1:BQ];

  // ---- BPR : module-body home
  lf_earl70 i_mod_BPR (
      .p0(sig[BPR-1:BQ]),
      .p1(sig[0 +: BPR]),
      .p2(sig[BPR +: 4]),
      .p3(sig[BPR]),
      .p4(sig[BPR-1:0]),
      .p5(sig[31:BPR]),
      .p6(BPR)
  );
  logic [31:0] c_BPR; assign c_BPR = sig[BPR-1:BQ];

  // ---- BLP : module-body home
  lf_earl70 i_mod_BLP (
      .p0(sig[BLP-1:BQ]),
      .p1(sig[0 +: BLP]),
      .p2(sig[BLP +: 4]),
      .p3(sig[BLP]),
      .p4(sig[BLP-1:0]),
      .p5(sig[31:BLP]),
      .p6(BLP)
  );
  logic [31:0] c_BLP; assign c_BLP = sig[BLP-1:BQ];

  // ---- BE0 : module-body home
  lf_earl70 i_mod_BE0 (
      .p0(sig[BE0-1:BQ]),
      .p1(sig[0 +: BE0]),
      .p2(sig[BE0 +: 4]),
      .p3(sig[BE0]),
      .p4(sig[BE0-1:0]),
      .p5(sig[31:BE0]),
      .p6(BE0)
  );
  logic [31:0] c_BE0; assign c_BE0 = sig[BE0-1:BQ];

  // ---- MPR : module-body home
  lf_earl70 i_mod_MPR (
      .p0(sig[MPR-1:BQ]),
      .p1(sig[0 +: MPR]),
      .p2(sig[MPR +: 4]),
      .p3(sig[MPR]),
      .p4(sig[MPR-1:0]),
      .p5(sig[31:MPR]),
      .p6(MPR)
  );
  logic [31:0] c_MPR; assign c_MPR = sig[MPR-1:BQ];

  // ---- MLP : module-body home
  lf_earl70 i_mod_MLP (
      .p0(sig[MLP-1:BQ]),
      .p1(sig[0 +: MLP]),
      .p2(sig[MLP +: 4]),
      .p3(sig[MLP]),
      .p4(sig[MLP-1:0]),
      .p5(sig[31:MLP]),
      .p6(MLP)
  );
  logic [31:0] c_MLP; assign c_MLP = sig[MLP-1:BQ];

  // ---- ALP : gen-for home
  for (genvar g_ALP = 0; g_ALP < 2; g_ALP++) begin: gf_ALP
    lf_earl70 i_gen_ALP (
      .p0(sig[ALP-1:BQ]),
      .p1(sig[0 +: ALP]),
      .p2(sig[ALP +: 4]),
      .p3(sig[ALP]),
      .p4(sig[ALP-1:0]),
      .p5(sig[31:ALP]),
      .p6(ALP)
    );
    logic [31:0] t_ALP;
    assign t_ALP = sig[ALP-1:BQ];
  end

  // ---- APR : gen-for home
  for (genvar g_APR = 0; g_APR < 2; g_APR++) begin: gf_APR
    lf_earl70 i_gen_APR (
      .p0(sig[APR-1:BQ]),
      .p1(sig[0 +: APR]),
      .p2(sig[APR +: 4]),
      .p3(sig[APR]),
      .p4(sig[APR-1:0]),
      .p5(sig[31:APR]),
      .p6(APR)
    );
    logic [31:0] t_APR;
    assign t_APR = sig[APR-1:BQ];
  end

  // ---- BPR : gen-for home
  for (genvar g_BPR = 0; g_BPR < 2; g_BPR++) begin: gf_BPR
    lf_earl70 i_gen_BPR (
      .p0(sig[BPR-1:BQ]),
      .p1(sig[0 +: BPR]),
      .p2(sig[BPR +: 4]),
      .p3(sig[BPR]),
      .p4(sig[BPR-1:0]),
      .p5(sig[31:BPR]),
      .p6(BPR)
    );
    logic [31:0] t_BPR;
    assign t_BPR = sig[BPR-1:BQ];
  end

  // ---- BLP : gen-for home
  for (genvar g_BLP = 0; g_BLP < 2; g_BLP++) begin: gf_BLP
    lf_earl70 i_gen_BLP (
      .p0(sig[BLP-1:BQ]),
      .p1(sig[0 +: BLP]),
      .p2(sig[BLP +: 4]),
      .p3(sig[BLP]),
      .p4(sig[BLP-1:0]),
      .p5(sig[31:BLP]),
      .p6(BLP)
    );
    logic [31:0] t_BLP;
    assign t_BLP = sig[BLP-1:BQ];
  end

  // ---- BE0 : gen-for home
  for (genvar g_BE0 = 0; g_BE0 < 2; g_BE0++) begin: gf_BE0
    lf_earl70 i_gen_BE0 (
      .p0(sig[BE0-1:BQ]),
      .p1(sig[0 +: BE0]),
      .p2(sig[BE0 +: 4]),
      .p3(sig[BE0]),
      .p4(sig[BE0-1:0]),
      .p5(sig[31:BE0]),
      .p6(BE0)
    );
    logic [31:0] t_BE0;
    assign t_BE0 = sig[BE0-1:BQ];
  end

  // ---- MPR : gen-for home
  for (genvar g_MPR = 0; g_MPR < 2; g_MPR++) begin: gf_MPR
    lf_earl70 i_gen_MPR (
      .p0(sig[MPR-1:BQ]),
      .p1(sig[0 +: MPR]),
      .p2(sig[MPR +: 4]),
      .p3(sig[MPR]),
      .p4(sig[MPR-1:0]),
      .p5(sig[31:MPR]),
      .p6(MPR)
    );
    logic [31:0] t_MPR;
    assign t_MPR = sig[MPR-1:BQ];
  end

  // ---- MLP : gen-for home
  for (genvar g_MLP = 0; g_MLP < 2; g_MLP++) begin: gf_MLP
    lf_earl70 i_gen_MLP (
      .p0(sig[MLP-1:BQ]),
      .p1(sig[0 +: MLP]),
      .p2(sig[MLP +: 4]),
      .p3(sig[MLP]),
      .p4(sig[MLP-1:0]),
      .p5(sig[31:MLP]),
      .p6(MLP)
    );
    logic [31:0] t_MLP;
    assign t_MLP = sig[MLP-1:BQ];
  end

  // ---- gen-scope LOCALPARAM and GENVAR bounds, gen-for home
  for (genvar g2 = 0; g2 < 2; g2++) begin: gf_GLP
    localparam int GLP = 16;
    lf_earl70 i_gen_GLP (
      .p0(sig[GLP-1:BQ]),
      .p1(sig[0 +: GLP]),
      .p2(sig[GLP +: 4]),
      .p3(sig[GLP]),
      .p4(sig[GLP-1:0]),
      .p5(sig[31:GLP]),
      .p6(GLP)
    );
  end
  for (genvar g3 = 1; g3 < 3; g3++) begin: gf_GV
    lf_earl70 i_gen_GV (
      .p0(sig[g3+8-1:BQ]),
      .p1(sig[0 +: g3+8]),
      .p2(sig[g3 +: 4]),
      .p3(sig[g3]),
      .p4(sig[g3+8-1:0]),
      .p5(sig[31:g3]),
      .p6(g3)
    );
  end
  assign o0 = c_ALP; assign o1 = sig;
endmodule

module top_earl70 (input [31:0] sig, output logic [31:0] o0, output logic [31:0] o1);
  m1_earl70 i_m1 (.sig(sig), .o0(o0), .o1(o1));
endmodule
