// r10v71 arm v2 — MEASUREMENT ONLY.  Symbol ORIGIN x spelling for the DIRECT
// part-select bound, gen-for / gen-if / nested-gen / module homes.
package pa_v71;
  parameter  int AP  = 16;
  localparam int ALP = 16;
  typedef enum logic [31:0] { AE0 = 32'd16, AE1 = 32'd17 } ae_t;
  typedef logic [15:0] aw_t;
  parameter  ae_t APE = AE0;          // parameter of an ENUM type
  parameter  aw_t APT = 16;           // parameter of a TYPEDEF'd type
endpackage
package pb_v71;
  parameter int BP = 16;
endpackage

module lav71 (
  input [47:0] b0, input [47:0] b1, input [47:0] b2, input [47:0] b3,
  input [47:0] b4, input [47:0] b5, input [47:0] b6, input [47:0] b7,
  input [47:0] b8, input [47:0] b9, input [47:0] ba, input [47:0] bb);
endmodule

module lgv71 (
  input [63:0] b0, input [63:0] b1, input [63:0] b2, input [63:0] b3,
  input [63:0] b4, input [63:0] b5, input [63:0] b6, input [63:0] b7,
  input [63:0] b8, input [63:0] b9, input [63:0] ba, input [63:0] bb);
endmodule

module m2_v71 import pa_v71::*; import pb_v71::BP; (
  input [63:0] sig, output logic [63:0] o0);
  parameter  int MP  = 16;
  localparam int MLP = 16;
  localparam int CLG = $clog2(65536);
  localparam int BIT = $bits(aw_t);
  localparam int SZP = $size(sig[15:0]);

  // module-body home
  lgv71 i_mod (
    .b0(sig[63:AP]), .b1(sig[63:ALP]), .b2(sig[63:AE0]), .b3(sig[63:APE]),
    .b4(sig[63:APT]), .b5(sig[63:BP]), .b6(sig[63:pa_v71::AP]),
    .b7(sig[63:MP]), .b8(sig[63:MLP]), .b9(sig[63:CLG]), .ba(sig[63:BIT]),
    .bb(sig[63:SZP])
  );
  // gen-for home
  for (genvar g = 0; g < 2; g++) begin: gfo
    localparam int GLP = 16;
    lgv71 i_gen (
      .b0(sig[63:AP]), .b1(sig[63:ALP]), .b2(sig[63:AE0]), .b3(sig[63:APE]),
      .b4(sig[63:APT]), .b5(sig[63:BP]), .b6(sig[63:pa_v71::AP]),
      .b7(sig[63:MP]), .b8(sig[63:MLP]), .b9(sig[63:GLP]), .ba(sig[63:g+16]),
      .bb(sig[63:CLG])
    );
  end
  // gen-if home
  if (MP == 16) begin: gif
    localparam int HLP = 16;
    lgv71 i_gen (
      .b0(sig[63:AP]), .b1(sig[63:ALP]), .b2(sig[63:AE0]), .b3(sig[63:APE]),
      .b4(sig[63:APT]), .b5(sig[63:BP]), .b6(sig[63:pa_v71::AP]),
      .b7(sig[63:MP]), .b8(sig[63:MLP]), .b9(sig[63:HLP]), .ba(sig[63:BIT]),
      .bb(sig[63:CLG])
    );
  end
  // nested gen home + INSTANCE ARRAY of three
  for (genvar g2 = 0; g2 < 2; g2++) begin: gout
    localparam int OLP = 16;
    for (genvar g3 = 0; g3 < 2; g3++) begin: gin
      localparam int ILP = 16;
      lgv71 i_gen (
        .b0(sig[63:AP]), .b1(sig[63:ALP]), .b2(sig[63:AE0]), .b3(sig[63:APE]),
        .b4(sig[63:APT]), .b5(sig[63:BP]), .b6(sig[63:pa_v71::AP]),
        .b7(sig[63:MP]), .b8(sig[63:OLP]), .b9(sig[63:ILP]), .ba(sig[63:BIT]),
        .bb(sig[63:CLG])
      );
      lav71 i_arr [2:0] (
        .b0(sig[63:AP]), .b1(sig[63:ALP]), .b2(sig[63:AE0]), .b3(sig[63:APE]),
        .b4(sig[63:APT]), .b5(sig[63:BP]), .b6(sig[63:pa_v71::AP]),
        .b7(sig[63:MP]), .b8(sig[63:OLP]), .b9(sig[63:ILP]), .ba(sig[63:BIT]),
        .bb(sig[63:CLG])
      );
    end
  end
  assign o0 = sig;
endmodule
