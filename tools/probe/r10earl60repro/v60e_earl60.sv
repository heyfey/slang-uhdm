// r10earl60 arm E — WHICH package members propagate their typespec, keyed on the
// SHAPE OF THE PACKAGE MEMBER'S OWN INITIALIZER.  The wide boundary caught
// r10earl55repro/a5_earl55.sv moving from one wrong answer to another on
// `localparam logic [0:0] K = pk5_55::PKW1;` where `PKW1 = {1{1'b1}}` -- and
// golden's own package listing keeps that Rhs as an OPERATION (a package never
// folds a replication, r10c9/b).  This arm asks the general question: when the
// package member's Rhs is not a folded constant, does the referring module still
// take the member's declared typespec?
package r_pkg;
  localparam logic [0:0]  P_repl  = {1{1'b1}};      // replication: pkg keeps an operation
  localparam logic [3:0]  P_cat   = {2'b10, 2'b01}; // concat
  localparam int          P_arith = 4 + 3;          // arithmetic
  localparam int          P_tern  = (1) ? 5 : 6;    // ternary
  localparam int          P_lit   = 9;              // literal
  localparam int          P_clog  = $clog2(16);     // system call
  localparam logic [11:0] P_vec   = 12'h380;        // sized literal
  typedef struct packed { logic [3:0] a; logic [3:0] b; } r_t;
  localparam r_t          P_ap    = '{a:4'h1, b:4'h2};  // assignment pattern
endpackage

module s_take ();                                   // r_pkg NOT imported
  localparam logic [0:0]  k_repl  = r_pkg::P_repl;
  localparam logic [3:0]  k_cat   = r_pkg::P_cat;
  localparam int          k_arith = r_pkg::P_arith;
  localparam int          k_tern  = r_pkg::P_tern;
  localparam int          k_lit   = r_pkg::P_lit;
  localparam int          k_clog  = r_pkg::P_clog;
  localparam logic [11:0] k_vec   = r_pkg::P_vec;
  localparam r_pkg::r_t   k_ap    = r_pkg::P_ap;
endmodule

module a1 ();
  s_take u0 ();
endmodule
