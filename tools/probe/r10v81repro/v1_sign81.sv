// r10v81 arm v1 — THE OVERRIDDEN x DECLARED-TYPE (SIGNEDNESS) AXIS.
// g2_enc81.sv folds ONLY `int unsigned` / `bit [3:0]` / untyped overridden
// cells; the `+TS` ref_typespec rule it measured lands on the SIGNED
// int_typespec sub-case of the NON-overridden fold.  This arm asks whether the
// SAME +TS rule fires on the OVERRIDDEN fold, which the shipped law would then
// get wrong (it attaches no typespec, ever).  MEASUREMENT ONLY.
module leafv1 (input logic ib, output logic o);
  assign o = ib;
endmodule

module midv1 #(
  parameter int           OSI = 1,   // SIGNED int,        overridden bare dec
  parameter integer       OIG = 1,   // SIGNED integer,    overridden bare dec
  parameter byte          OBY = 1,   // SIGNED byte,       overridden bare dec
  parameter signed [7:0]  OSB = 1,   // SIGNED packed,     overridden bare dec
  parameter logic [7:0]   OLG = 1,   // logic vector,      overridden bare dec
  parameter bit [3:0]     OBT = 1,   // bit vector,        overridden bare dec
  parameter int unsigned  OIU = 1,   // int unsigned,      overridden bare dec
  parameter               OUT = 1,   // untyped,           overridden bare dec
  parameter shortint      OSH = 1,   // SIGNED shortint,   overridden bare dec
  parameter longint       OLN = 1,   // SIGNED longint,    overridden bare dec
  parameter real          ORE = 1.0  // real (control: never an index)
) (
  input  logic [15:0] w,
  output logic [15:0] y
);
  leafv1 uOSI (.ib(w[OSI]), .o(y[0]));
  leafv1 uOIG (.ib(w[OIG]), .o(y[1]));
  leafv1 uOBY (.ib(w[OBY]), .o(y[2]));
  leafv1 uOSB (.ib(w[OSB]), .o(y[3]));
  leafv1 uOLG (.ib(w[OLG]), .o(y[4]));
  leafv1 uOBT (.ib(w[OBT]), .o(y[5]));
  leafv1 uOIU (.ib(w[OIU]), .o(y[6]));
  leafv1 uOUT (.ib(w[OUT]), .o(y[7]));
  leafv1 uOSH (.ib(w[OSH]), .o(y[8]));
  leafv1 uOLN (.ib(w[OLN]), .o(y[9]));
  // body-position twins (controls)
  assign y[10] = w[OSI];
  assign y[11] = w[OIU];
  logic unused_r; assign unused_r = (ORE > 0.0);
endmodule

module topv1 (input logic [15:0] w, output logic [15:0] y);
  midv1 #(.OSI(2), .OIG(3), .OBY(4), .OSB(5), .OLG(6),
          .OBT(7), .OIU(8), .OUT(9), .OSH(10), .OLN(11)) iv (.w(w), .y(y));
endmodule
