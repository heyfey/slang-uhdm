// r11u91 arm p1 — THE PACKAGE-HOMED INNER CHAIN (r11u89's R1 / pass-88's R0).
// `logic [7:0] N = pkg::P` never reaches `valueRange` through the landed
// module road: `CompileExpression.cpp:2729-2751` CLONES the package's
// ELABORATED param_assign constant (typespec and all), and
// `DesignElaboration.cpp:2565` then calls `adjustSize` with the READER's
// typespec — which keeps a `vpiDecConst`'s own width and re-sizes every other
// const type.  `valueRange`'s THIRD argument is the clone's typespec, i.e. the
// PACKAGE parameter's declared one, so the reader's own declaration gets no
// vote on the signedness at all.
package p1p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int                 PI   = 16'd5;    // signed int, DEC, Bits 32
  localparam logic [15:0]        PU   = 16'd7;    // unsigned logic, DEC
  localparam logic signed [15:0] PS   = 16'd9;    // signed logic, DEC
  localparam bit signed [7:0]    PBS  = 8'd3;     // signed bit, DEC
  localparam                     PIMP = 16'd11;   // implicit, DEC
  localparam int                 PH   = 8'hA;     // signed int, HEX
  localparam shortint            PSH  = 16'd4;    // an abstained atom kind
  localparam int                 PNG  = -3;       // an INT const
endpackage
module p1_pkgin91;
  localparam logic [7:0] R1  = p1p::PI;    // DEC: keeps the PACKAGE's 32, /S
  localparam logic [7:0] R2  = p1p::PU;    // DEC: keeps 16, unsigned
  localparam logic [7:0] R3  = p1p::PS;    // DEC: keeps 16, /S
  localparam logic [7:0] R4  = p1p::PBS;   // DEC: keeps 8, /S
  localparam logic [7:0] R5  = p1p::PIMP;  // implicit package: the literal's 16
  localparam logic [7:0] R6  = p1p::PH;    // HEX: re-sized to the reader's 8
  localparam logic [7:0] R7  = p1p::PSH;   // an atom kind valueRange abstains
  localparam int         R8  = p1p::PU;    // THE SUPPRESSION TEST: signed
                                           // reader over an UNSIGNED package
  localparam int         R9  = p1p::PI;    // a signed reader, same answer
  localparam logic [7:0] R10 = R1;         // a chain THROUGH the package-fed hop
  localparam             R11 = p1p::PI;    // no declared type: no adjustSize,
                                           // no valueRange
  localparam logic [7:0] R12 = p1p::PNG;   // INT const: re-sized, /S
  localparam p1p::t A = '{bail: 8'hxA, a: R1, b: R2, c: R3, d: R4,
                          e: R5, f: R6, g: R7};
  localparam p1p::t B = '{bail: 8'hxA, a: R8, b: R9, c: R10, d: R11,
                          e: R12, f: R1, g: R3};
  p1_sink #(.R(A)) s1();
  p1_sink #(.R(B)) s2();
endmodule
module p1_sink #(parameter p1p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
