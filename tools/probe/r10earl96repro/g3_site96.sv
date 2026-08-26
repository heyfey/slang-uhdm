// r10earl96 arm g3 — USE SITES of a package SCALAR typedef inside a module
// that wildcard-imports it: port, net, variable, parameter (scalar and
// unpacked-array), cast target, a NESTED typedef of it, and a function
// return.  MEASUREMENT ONLY.
package p3s96;
  typedef logic [31:0] u_t;
  localparam u_t PARR [3] = '{ 32'h1, 32'h2, 32'h3 };
  localparam u_t PSCA     = 32'h4;
endpackage

module m3s96
  import p3s96::*;
(
  input  u_t        p_i,        // PORT of the typedef
  output logic [31:0] o_o
);
  u_t              n_net;       // NET of the typedef
  typedef u_t      nest_t;      // NESTED typedef of the typedef
  nest_t           n_nest;
  localparam u_t   LSCA     = 32'h9;
  localparam u_t   LARR [2] = '{ 32'ha, 32'hb };

  function automatic u_t f3s96(input u_t x);   // function RETURN + io_decl
    u_t loc;                                   // function-local VARIABLE
    loc = x + LSCA;
    return loc;
  endfunction

  always_comb begin
    automatic u_t v_var = p_i;                 // procedural VARIABLE
    n_nest = v_var;
  end
  assign n_net = u_t'(p_i);                    // CAST TARGET
  assign o_o   = n_net ^ n_nest ^ f3s96(p_i) ^ PARR[1] ^ PSCA ^ LARR[1];
endmodule

module top3s96 (input logic [31:0] i_i, output logic [31:0] a_o);
  m3s96 u_a (.p_i(i_i), .o_o(a_o));
endmodule
