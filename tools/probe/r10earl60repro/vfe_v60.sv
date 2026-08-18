// v60 VERIFIER arm E — the package member's OWN initializer shape, extended
// past v60e: a CAST, a bare package-to-package ref, a $bits fold, a
// STREAMING concat, a unary op, a comparison, a hierarchical-free func call,
// an unpacked array, and a member whose init is a CONCAT nested inside an
// ARITHMETIC op (operation at the top, not a concat).
package sp;
  localparam int          I_lit   = 9;
  localparam int          I_cast  = int'(3.7);
  localparam logic [7:0]  I_szcast= 8'(3);
  localparam int          I_bits  = $bits(logic [7:0]);
  localparam int          I_un    = -(4);
  localparam bit          I_cmp   = (3 > 2);
  localparam logic [3:0]  I_catop = {2'b10, 2'b01} + 4'd1;  // op at the TOP
  localparam logic [3:0]  I_cat   = {2'b10, 2'b01};         // concat at TOP
  localparam int          I_arr [0:1] = '{1, 2};            // UNPACKED array
  function automatic int fq (input int x); return x + 1; endfunction
  localparam int          I_call  = fq(2);
endpackage

module s_take2 ();
  localparam int         t_lit    = sp::I_lit;
  localparam int         t_cast   = sp::I_cast;
  localparam logic [7:0] t_szcast = sp::I_szcast;
  localparam int         t_bits   = sp::I_bits;
  localparam int         t_un     = sp::I_un;
  localparam bit         t_cmp    = sp::I_cmp;
  localparam logic [3:0] t_catop  = sp::I_catop;
  localparam logic [3:0] t_cat    = sp::I_cat;
  localparam int         t_call   = sp::I_call;
  localparam int         t_arr [0:1] = sp::I_arr;
  logic [t_lit-1:0] d;
endmodule

module a1 ();
  s_take2 u0 ();
endmodule
