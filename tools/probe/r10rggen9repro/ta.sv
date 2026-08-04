// r10rggen9 ta: rggen_register_common:104 `assign register_if.status =
// RGGEN_OKAY;` — golden's cont_assign Rhs is a LOC-LESS 2-bit BIN constant
// (2'b00, vpiBinaryConst) where we keep the symbolic ref_obj.  One shape per
// candidate distinguisher: interface-signal LHS vs plain net LHS, wildcard
// import vs package-qualified read, bare member vs member inside an operation,
// and a plain (non-enum) package parameter as the control.
package p;
  typedef enum logic [1:0] {
    OKAY  = 2'b00,
    ERR   = 2'b10
  } status_e;
  parameter int PC = 7;
endpackage

interface sif;
  logic [1:0] status;
  logic [1:0] status2;
  modport m (output status, output status2);
endinterface

module mid
  import p::*;
#(parameter bit E = 0)
(
  sif.m sm,
  output logic [1:0] w0,
  output logic [1:0] w1,
  output logic [1:0] w2,
  output logic [1:0] w3,
  output int         w4
);
  // A: interface-signal LHS, bare wildcard-imported enum member (the Rggen shape)
  assign sm.status  = OKAY;
  // B: interface-signal LHS, package-QUALIFIED enum member
  assign sm.status2 = p::ERR;
  // C: plain net LHS, bare enum member
  assign w0 = OKAY;
  // D: plain net LHS, package-qualified enum member
  assign w1 = p::OKAY;
  // E: enum member inside an operation
  assign w2 = E ? ERR : OKAY;
  // F: enum member through a cast
  assign w3 = status_e'(2'b10);
  // G: control — a plain package PARAMETER read
  assign w4 = PC;
endmodule

module top (output logic [1:0] a, output logic [1:0] b, output logic [1:0] c,
            output logic [1:0] d, output int e);
  sif u_sif ();
  mid #(.E(1)) u (u_sif, a, b, c, d, e);
endmodule
