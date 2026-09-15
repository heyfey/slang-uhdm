// h15 — THE RECURSION ARM.  An `int unsigned` localparam whose initializer is
// a BARE reference to a SIGNED `int` localparam: `paramValueSigned89` says
// SIGNED (the stored Value's sign follows the referenced constant), the
// declared type says unsigned.  Decides whether this pass takes the recursive
// form or only the suppressing intersection.
module h15 (input logic c, output logic o);
  localparam int Q = 4;
  localparam int unsigned P = Q;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
