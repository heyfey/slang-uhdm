// r10earl55 a3 — THE PINMUX SPLIT.  Inside ONE parameterless instance golden
// gives `MioPeriphHasSleepMode` (32 bits) a LOC-LESS int_typespec and
// `DioPeriphHasSleepMode` (15 bits) a LOC-LESS logic_typespec.  a2's c3_55
// reproduced the two declarations verbatim and got int_typespec for BOTH, so
// the split is NOT the width, the count's package origin, or the declaration
// order.  The one asymmetry left in pinmux.sv is that `logic [NDioPads-1:0]`
// is ALSO the written type of ports and signals in the same module
// (lines 31-42, 84-87) while `[NMioPeriphOut-1:0]` is only ever an untyped
// `input` (lines 27-28).  a3 tests exactly that: does a SECOND declaration of
// the same vector type elsewhere in the module change the fold's typespec?
package pk3_55;
  parameter int N15 = 15;
  parameter int N32 = 32;
endpackage

module a3_earl55;
  d1_55 u_d1 (.o());
  d2_55 u_d2 (.o(), .p());
  d3_55 u_d3 (.o());
  d4_55 u_d4 (.o(), .r(15'h0));
  d5_55 u_d5 (.o(), .p());
  d6_55 u_d6 (.o());
endmodule

// CONTROL: nothing else in the module has this type
module d1_55 (output logic o);
  localparam logic [pk3_55::N15-1:0] Q = {pk3_55::N15{1'b1}};
  assign o = Q[0];
endmodule

// a PORT with the same written vector type (the pinmux `output logic` shape)
module d2_55 (output logic o, output logic [pk3_55::N15-1:0] p);
  localparam logic [pk3_55::N15-1:0] Q = {pk3_55::N15{1'b1}};
  assign o = Q[0];
  assign p = Q;
endmodule

// an internal SIGNAL with the same written vector type
module d3_55 (output logic o);
  logic [pk3_55::N15-1:0] w;
  localparam logic [pk3_55::N15-1:0] Q = {pk3_55::N15{1'b1}};
  assign w = Q;
  assign o = w[0];
endmodule

// an UNTYPED input port of the same width (the pinmux `input [N-1:0]` shape)
module d4_55 (output logic o, input [pk3_55::N15-1:0] r);
  localparam logic [pk3_55::N15-1:0] Q = {pk3_55::N15{1'b1}};
  assign o = Q[0] ^ r[0];
endmodule

// THE PINMUX SPLIT: two folds, 32 and 15, and only the 15-bit type is also a
// port's type.  If the theory holds, M32 keeps int_typespec and D15 flips.
module d5_55 (output logic o, output logic [pk3_55::N15-1:0] p);
  localparam logic [pk3_55::N32-1:0] M32 = {pk3_55::N32{1'b1}};
  localparam logic [pk3_55::N15-1:0] D15 = {pk3_55::N15{1'b1}};
  localparam logic [pk3_55::N15-1:0] E15 = {pk3_55::N15{1'b1}};
  assign o = M32[0] ^ D15[0] ^ E15[0];
assign p = D15;
endmodule

// a LITERAL-width port instead of a package-parameter width
module d6_55 (output logic o);
  logic [14:0] w2;
  localparam logic [pk3_55::N15-1:0] Q = {pk3_55::N15{1'b1}};
  assign w2 = Q;
  assign o = w2[0];
endmodule
