// r10earl96 arm g5 — THE NEGATIVE CONTROLS the law must NOT move: the
// package's OWN two views of its unpacked-array-of-typedef parameter (whose
// alias target stays QUALIFIED), a module's OWN LOCAL typedef used the same
// way (never qualified at all), and a module localparam of an IMPORTED
// typedef declared in the module itself (not a materialized import copy).
// MEASUREMENT ONLY.
package p5n96;
  typedef logic [31:0] n_t;
  localparam n_t PKGARR [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
  function automatic n_t f5n96(input n_t x);
    n_t loc;
    loc = x + PKGARR[0];
    return loc;
  endfunction
endpackage

module m5own96 (output logic [31:0] o_o);
  typedef logic [31:0] own_t;                    // MODULE-LOCAL typedef
  localparam own_t OWNARR [4] = '{ 32'h5, 32'h6, 32'h7, 32'h8 };
  assign o_o = OWNARR[2];
endmodule

module m5loc96 import p5n96::*; (output logic [31:0] o_o);
  localparam n_t LOCARR [4] = '{ 32'h9, 32'ha, 32'hb, 32'hc };  // module's OWN
  assign o_o = LOCARR[2] ^ PKGARR[1] ^ p5n96::f5n96(32'h1);
endmodule

module top5n96 (output logic [31:0] a_o);
  logic [31:0] w, x;
  m5own96 u_o (.o_o(w));
  m5loc96 u_l (.o_o(x));
  assign a_o = w ^ x;
endmodule
