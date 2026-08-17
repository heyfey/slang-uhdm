// r10earl52 verifier v3 — the CSR_MISA_MXL shape: a package parameter with a
// SIZED-DECIMAL literal, WILDCARD-IMPORTED into a module that is instantiated,
// so the module gets a MATERIALIZED def-view copy AND an elab copy.  golden
// keeps DEC:1 "2'd1" in the DEF copy and INT:1 "1" in the ELAB one.
package v3p_earl52;
  parameter logic [1:0] K_dec = 2'd1;
  parameter logic [1:0] K_bin = 2'b01;
  parameter logic [1:0] K_hex = 2'h1;
  parameter int         K_i   = 1'b1;
endpackage
module v3sub_earl52 #(parameter int W = 4) ();
  import v3p_earl52::*;
  localparam logic [1:0] U_dec = K_dec;
  wire [1:0] w1;
  assign w1 = K_dec;
endmodule
module v3_earl52 ();
  v3sub_earl52 u1 ();
endmodule
