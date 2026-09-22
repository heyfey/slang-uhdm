// v11u84 v7 — LAW C's SLOT, WIDENED: decl / import / decl over BOTH vectors,
// with the imported entries themselves carrying LAW A's surface, plus a
// package whose ONLY own entries follow a parameter and a typedef (which the
// census does not count) and a package with an import LAST.
package om1;
  typedef logic [7:0] ow_t;
  wire  ow_t  o_wtd;             // LAW A cell
  wire  [7:0] o_net;
  logic [7:0] o_var = 8'd4;
  logic [7:0] o_uarr [0:2];
endpackage

package om2;
  logic [7:0] o2_var;
endpackage

package on1;                     // decl, import, decl, import, decl
  logic [7:0] a_var;
  wire  [7:0] a_net;
  import om1::*;
  logic [7:0] b_var;
  wire  [7:0] b_net;
  import om2::*;
  logic [7:0] c_var;
  wire  [7:0] c_net;
endpackage

package on2;                     // parameter/typedef first, then decl, import
  parameter int ON2P = 2;
  typedef logic [3:0] on2_t;
  logic [7:0] d_var;
  import om1::*;
endpackage

package on3;                     // the import is the LAST member
  wire  [7:0] e_net;
  logic [7:0] e_var;
  import om2::*;
endpackage

module dut (output logic [31:0] o);
  import on1::*;
  assign o = {24'd0, a_var ^ c_var};
endmodule
