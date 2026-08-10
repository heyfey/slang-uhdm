// ds19.sv — § contAssignDriveStrength19's matrix.  cont_assign::Compare
// compares vpiStrength0 and vpiStrength1 (UHDM cont_assign.cpp:112/117), and
// slang-uhdm never wrote either, so every `assign (strong0, strong1) ...`
// reads r = 64 - 0 against golden.  Two Earlgrey heads share ONE object:
// def:work@prim_generic_pad_wrapper and work@padring, both r=64 at
// prim_generic_pad_wrapper.sv:40:29.
//
// The matrix covers every drive-strength keyword pair, both written orders,
// the net-declaration-assignment flavour, and a plain `assign` control.
module ds19 (
  input  logic a,
  input  logic b,
  inout  wire  io
);
  wire w0, w1, w2, w3, w4, w5, w6, w7, w8, w9;

  // control: no strength at all
  assign w0 = a & b;

  // (strength0, strength1) written in that order
  assign (strong0, strong1) w1 = a;
  assign (pull0, pull1)     w2 = a;
  assign (highz0, weak1)    w3 = a;
  assign (weak0, highz1)    w4 = a;
  assign (weak0, weak1)     w5 = a;
  assign (supply0, supply1) w6 = a;

  // the REVERSE written order (LRM allows strength1 first)
  assign (strong1, pull0)   w7 = b;
  assign (supply1, supply0) w8 = b;
  assign (weak1, strong0)   w9 = b;

  // net-declaration assignment with a strength
  wire (pull0, strong1) nd0 = a;
  wire nd1 = b;

  assign io = w1 ^ w2 ^ w3 ^ w4 ^ w5 ^ w6 ^ w7 ^ nd0 ^ nd1 ^ w0;
endmodule
