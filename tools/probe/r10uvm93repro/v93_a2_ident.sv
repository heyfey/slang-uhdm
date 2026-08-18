// v93 A2 — identifier slice sizes: typedefs, pkg-scoped, params, class types.
package p2;
  typedef logic [7:0] pk_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;
  typedef enum logic [2:0] { E0, E1 } pe_t;
  parameter int PW = 5;
endpackage
module a2_ident;
  import p2::*;
  typedef logic [15:0] loc_t;
  typedef bit [2:0] small_t;
  typedef logic [7:0] arr_t [0:3];
  parameter int WREN = 7;
  localparam int LP = 9;
  logic [63:0] v, r;
  initial begin
    r = { << loc_t     { v } };
    r = { << small_t   { v } };
    r = { << arr_t     { v } };
    r = { << p2::pk_t  { v } };
    r = { << p2::ps_t  { v } };
    r = { << p2::pe_t  { v } };
    r = { << pk_t      { v } };
    r = { << WREN      { v } };
    r = { << LP        { v } };
    r = { << p2::PW    { v } };
  end
endmodule
