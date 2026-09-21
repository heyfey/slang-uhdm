// v11u79 q5 — IMPORT REACH.  LAW A makes a wildcard-import clone reproduce the
// home package's WHOLE signal vector, nets included, and transitively.  Does
// golden's pb/pc listing really carry pa's net and unpacked array, and does an
// EXPLICIT import clone anything at all?
package pa5;
  wire [7:0]  a_net;
  logic [7:0] a_uarr [0:1];
  typedef struct packed { int x; logic [7:0] y; } asi_t;
  asi_t       a_struct;
  logic [7:0] a_var;
  typedef logic [7:0] aw_t;
  wire aw_t   a_wtd;
endpackage

package pb5;                 // WILDCARD import
  import pa5::*;
  logic [7:0] b_own;
endpackage

package pc5;                 // TRANSITIVE wildcard
  import pb5::*;
  logic [7:0] c_own;
endpackage

package pd5;                 // EXPLICIT import
  import pa5::a_net;
  import pa5::a_uarr;
  import pa5::a_var;
  logic [7:0] d_own;
endpackage

module dut (output logic [31:0] o);
  import pa5::*; import pb5::*; import pc5::*; import pd5::*;
  assign o = {24'd0, a_net} ^ {24'd0, a_uarr[0]} ^ {24'd0, a_var}
           ^ {24'd0, a_wtd} ^ {24'd0, b_own} ^ {24'd0, c_own} ^ {24'd0, d_own};
endmodule
