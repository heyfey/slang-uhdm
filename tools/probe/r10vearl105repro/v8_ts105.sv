// r10v105 v8 — TYPEDEF, ENUM and PACKAGE sources.  The clone arm MINTS a bare
// `int_typespec` field for field and copies neither `Typedef_alias` nor any
// range subtree; `typespec::Compare` DOES walk `Typedef_alias`.  Also: the same
// parameter read in a SUBSTITUTING position and a NON-SUBSTITUTING one in the
// SAME scope, as its own pair.
package v8_pkg105;
  localparam int PKGI = 6;
  localparam logic [3:0] PKGV = {2{2'b01}};
endpackage

typedef int v8_myint_t;
typedef bit signed [3:0] v8_bs_t;

module v8_leaf105 (input logic [31:0] sig, output logic [63:0] z);
  typedef enum int { E0 = 0, E1 = 1, E2 = 2 } v8_e_t;
  localparam v8_myint_t TD  = 4'hA;      // a TYPEDEF'd int: Typedef_alias
  localparam v8_bs_t    BS  = 4'b0101;   // a typedef'd signed bit vector
  localparam v8_e_t     EN  = E2;        // an ENUM-typed parameter
  localparam int        PL  = 5;
  logic [63:0] nonsub;
  assign nonsub = PL ^ sig;              // MODULE scope: NON-substituting
  for (genvar i = 0; i < 2; i++) begin : gen_ts
    logic [63:0] t0,t1,t2,t3,t4,t5;
    assign t0 = TD  ^ sig;
    assign t1 = BS  ^ sig;
    assign t2 = EN  ^ sig;
    assign t3 = PL  ^ sig;               // SUBSTITUTING, same param as `nonsub`
    assign t4 = v8_pkg105::PKGI ^ sig;   // a PACKAGE parameter, qualified
    assign t5 = v8_pkg105::PKGV ^ sig;
  end
  assign z = 64'b0;
endmodule

module v8_ts105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  v8_leaf105 u_leaf (.sig(sig), .z(zc));
  assign z = zc;
endmodule
