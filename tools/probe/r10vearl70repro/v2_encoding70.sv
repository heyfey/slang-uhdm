// r10vearl70 adversarial arm: signedness, literal bases, declared widths,
// expression initializers, and both operation-bound positions.
package ve70_pkg;
  parameter int SDEC = 16;
  parameter int signed SSH = 8'sh10;
  parameter int signed SSB = 8'sb00010000;
  parameter int signed SSD = 8'sd16;
  parameter int signed SSO = 8'so20;
  parameter logic signed [7:0] VSH = 8'sh10;
  parameter logic signed [7:0] VSB = 8'sb0001_0000;
  parameter logic signed [7:0] VSD = 8'sd16;
  parameter logic signed [7:0] VSO = 8'so20;
  parameter logic [7:0] UHEX = 8'h10;
  parameter bit [6:0] UEXPR = 7'(8 + 8);
  parameter byte BYT = 16;
  parameter integer IEXPR = 8 + 8;
  parameter UEXPR64 = 8 + 8;
  parameter UBHEX = 8'h10;
  parameter int NEG = -16;
  parameter logic [7:0] UNK = 8'hx;
endpackage

module ve70_leaf(
  input [127:0] p0, p1, p2, p3, p4, p5, p6, p7, p8,
  input [127:0] p9, p10, p11, p12, p13, p14, p15, p16,
  input [127:0] q0, q1, q2, q3, q4, q5, q6, q7, q8,
  input [127:0] q9, q10, q11, q12, q13, q14, q15, q16
);
endmodule

module ve70_mid import ve70_pkg::*; (input [255:0] sig);
  for (genvar i = 0; i < 2; i++) begin: g
    ve70_leaf u(
      .p0(sig[SDEC-1:0]), .q0(sig[127:SDEC+1]),
      .p1(sig[SSH-1:0]), .q1(sig[127:SSH+1]),
      .p2(sig[SSB-1:0]), .q2(sig[127:SSB+1]),
      .p3(sig[SSD-1:0]), .q3(sig[127:SSD+1]),
      .p4(sig[SSO-1:0]), .q4(sig[127:SSO+1]),
      .p5(sig[VSH-1:0]), .q5(sig[127:VSH+1]),
      .p6(sig[VSB-1:0]), .q6(sig[127:VSB+1]),
      .p7(sig[VSD-1:0]), .q7(sig[127:VSD+1]),
      .p8(sig[VSO-1:0]), .q8(sig[127:VSO+1]),
      .p9(sig[UHEX-1:0]), .q9(sig[127:UHEX+1]),
      .p10(sig[UEXPR-1:0]), .q10(sig[127:UEXPR+1]),
      .p11(sig[BYT-1:0]), .q11(sig[127:BYT+1]),
      .p12(sig[IEXPR-1:0]), .q12(sig[127:IEXPR+1]),
      .p13(sig[UEXPR64-1:0]), .q13(sig[127:UEXPR64+1]),
      .p14(sig[UBHEX-1:0]), .q14(sig[127:UBHEX+1]),
      // Negative and unknown leaves are refusals while their enclosing
      // operations remain legal, constant part-select bounds.
      .p15(sig[NEG+32-1:0]), .q15(sig[127:NEG+17]),
      .p16(sig[(UNK === 8'hx ? 16 : UNK)-1:0]),
      .q16(sig[127:(UNK === 8'hx ? 16 : UNK)+1])
    );
  end
endmodule

module ve70_top(input [255:0] sig);
  ve70_mid u(.sig(sig));
endmodule
