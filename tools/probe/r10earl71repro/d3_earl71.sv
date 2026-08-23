// r10earl71 arm d3 — MEASUREMENT ONLY.  The ENCODING of the locless
// enum_const golden mints for a DIRECT part-select bound in a gen-for,
// one package parameter INIT SHAPE per cell.
package pz3_earl71;
  parameter int ZA = 10;
endpackage

package pe3_earl71;
  parameter  int A1  = 20;
  parameter  int A2  = 8+8;
  parameter  int A3  = 8*2;
  parameter  int A4  = 40/2;
  parameter  int A5  = A1;
  parameter  int A6  = A1+4;
  parameter  int A7  = A1-4;
  parameter  int A8  = A1*1;
  parameter  int A9  = A1/2;
  parameter  int A10 = A1%7;
  parameter  int A11 = A1>>1;
  parameter  int A12 = A1<<0;
  parameter  int A13 = $clog2(A1);
  parameter  int A14 = A1==1 ? 1 : 2;
  parameter  int A15 = pz3_earl71::ZA;
  parameter  int A16 = pz3_earl71::ZA+1;
  parameter  int A17 = (A1);
  parameter  int A18 = A1 > 3;
  parameter  int A19 = -A1+30;
  parameter      A20 = 20;
  parameter  int A21 = A6;
  localparam int A22 = A1-4;
  parameter  int A23 = A1 & 31;
  parameter  int A24 = A1 | 0;
  parameter  int A25 = A1 ^ 0;
endpackage

module lf73 (input [31:0] r0, input [31:0] r1);
endmodule

module m3_earl71 import pe3_earl71::*; (input [63:0] sig, output logic [31:0] o0);
  for (genvar g_A1 = 0; g_A1 < 2; g_A1++) begin: gf_A1
    lf73 i_gen (.r0(sig[63:A1]), .r1(sig[A1:0]));
  end
  for (genvar g_A2 = 0; g_A2 < 2; g_A2++) begin: gf_A2
    lf73 i_gen (.r0(sig[63:A2]), .r1(sig[A2:0]));
  end
  for (genvar g_A3 = 0; g_A3 < 2; g_A3++) begin: gf_A3
    lf73 i_gen (.r0(sig[63:A3]), .r1(sig[A3:0]));
  end
  for (genvar g_A4 = 0; g_A4 < 2; g_A4++) begin: gf_A4
    lf73 i_gen (.r0(sig[63:A4]), .r1(sig[A4:0]));
  end
  for (genvar g_A5 = 0; g_A5 < 2; g_A5++) begin: gf_A5
    lf73 i_gen (.r0(sig[63:A5]), .r1(sig[A5:0]));
  end
  for (genvar g_A6 = 0; g_A6 < 2; g_A6++) begin: gf_A6
    lf73 i_gen (.r0(sig[63:A6]), .r1(sig[A6:0]));
  end
  for (genvar g_A7 = 0; g_A7 < 2; g_A7++) begin: gf_A7
    lf73 i_gen (.r0(sig[63:A7]), .r1(sig[A7:0]));
  end
  for (genvar g_A8 = 0; g_A8 < 2; g_A8++) begin: gf_A8
    lf73 i_gen (.r0(sig[63:A8]), .r1(sig[A8:0]));
  end
  for (genvar g_A9 = 0; g_A9 < 2; g_A9++) begin: gf_A9
    lf73 i_gen (.r0(sig[63:A9]), .r1(sig[A9:0]));
  end
  for (genvar g_A10 = 0; g_A10 < 2; g_A10++) begin: gf_A10
    lf73 i_gen (.r0(sig[63:A10]), .r1(sig[A10:0]));
  end
  for (genvar g_A11 = 0; g_A11 < 2; g_A11++) begin: gf_A11
    lf73 i_gen (.r0(sig[63:A11]), .r1(sig[A11:0]));
  end
  for (genvar g_A12 = 0; g_A12 < 2; g_A12++) begin: gf_A12
    lf73 i_gen (.r0(sig[63:A12]), .r1(sig[A12:0]));
  end
  for (genvar g_A13 = 0; g_A13 < 2; g_A13++) begin: gf_A13
    lf73 i_gen (.r0(sig[63:A13]), .r1(sig[A13:0]));
  end
  for (genvar g_A14 = 0; g_A14 < 2; g_A14++) begin: gf_A14
    lf73 i_gen (.r0(sig[63:A14]), .r1(sig[A14:0]));
  end
  for (genvar g_A15 = 0; g_A15 < 2; g_A15++) begin: gf_A15
    lf73 i_gen (.r0(sig[63:A15]), .r1(sig[A15:0]));
  end
  for (genvar g_A16 = 0; g_A16 < 2; g_A16++) begin: gf_A16
    lf73 i_gen (.r0(sig[63:A16]), .r1(sig[A16:0]));
  end
  for (genvar g_A17 = 0; g_A17 < 2; g_A17++) begin: gf_A17
    lf73 i_gen (.r0(sig[63:A17]), .r1(sig[A17:0]));
  end
  for (genvar g_A18 = 0; g_A18 < 2; g_A18++) begin: gf_A18
    lf73 i_gen (.r0(sig[63:A18]), .r1(sig[A18:0]));
  end
  for (genvar g_A19 = 0; g_A19 < 2; g_A19++) begin: gf_A19
    lf73 i_gen (.r0(sig[63:A19]), .r1(sig[A19:0]));
  end
  for (genvar g_A20 = 0; g_A20 < 2; g_A20++) begin: gf_A20
    lf73 i_gen (.r0(sig[63:A20]), .r1(sig[A20:0]));
  end
  for (genvar g_A21 = 0; g_A21 < 2; g_A21++) begin: gf_A21
    lf73 i_gen (.r0(sig[63:A21]), .r1(sig[A21:0]));
  end
  for (genvar g_A22 = 0; g_A22 < 2; g_A22++) begin: gf_A22
    lf73 i_gen (.r0(sig[63:A22]), .r1(sig[A22:0]));
  end
  for (genvar g_A23 = 0; g_A23 < 2; g_A23++) begin: gf_A23
    lf73 i_gen (.r0(sig[63:A23]), .r1(sig[A23:0]));
  end
  for (genvar g_A24 = 0; g_A24 < 2; g_A24++) begin: gf_A24
    lf73 i_gen (.r0(sig[63:A24]), .r1(sig[A24:0]));
  end
  for (genvar g_A25 = 0; g_A25 < 2; g_A25++) begin: gf_A25
    lf73 i_gen (.r0(sig[63:A25]), .r1(sig[A25:0]));
  end
  assign o0 = sig[31:0];
endmodule

module top_earl73 (input [63:0] sig, output logic [31:0] o0);
  m3_earl71 i_m3 (.sig(sig), .o0(o0));
endmodule
