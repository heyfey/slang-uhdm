// r10earl96 arm g1 — TYPEDEF KINDS at the head's exact shape: an UNPACKED-
// ARRAY parameter whose ELEMENT is a package typedef, declared in a package
// that a module WILDCARD-IMPORTS, read in the module and instantiated.
// MEASUREMENT ONLY.
package p1k96;
  typedef logic [31:0]                       vec_t;   // scalar vector typedef
  typedef enum logic [1:0] { E0, E1, E2 }    en_t;    // enum typedef
  typedef struct packed { logic [3:0] a;
                          logic [3:0] b; }   st_t;    // packed struct typedef
  typedef logic [1:0][3:0]                   pk_t;    // packed-array typedef
  typedef vec_t                              vec2_t;  // typedef OF a typedef

  localparam vec_t  VA [4] = '{ 32'h1, 32'h2, 32'h3, 32'h4 };
  localparam en_t   EA [2] = '{ E1, E2 };
  localparam st_t   SA [2] = '{ 8'h11, 8'h22 };
  localparam pk_t   PA [2] = '{ 8'h33, 8'h44 };
  localparam vec2_t WA [2] = '{ 32'h5, 32'h6 };
  localparam vec_t  SCALAR = 32'h7;                   // scalar, not an array
endpackage

module m1k96
  import p1k96::*;
(
  input  logic       clk_i,
  output logic [31:0] o1_o, o2_o, o3_o, o4_o, o5_o, o6_o
);
  assign o1_o = VA[1];
  assign o2_o = 32'(EA[0]);
  assign o3_o = 32'(SA[1]);
  assign o4_o = 32'(PA[0]);
  assign o5_o = WA[1];
  assign o6_o = SCALAR;
endmodule

module top1k96 (input logic clk_i, output logic [31:0] a_o);
  logic [31:0] w1, w2, w3, w4, w5, w6;
  m1k96 u_a (.clk_i(clk_i), .o1_o(w1), .o2_o(w2), .o3_o(w3),
             .o4_o(w4), .o5_o(w5), .o6_o(w6));
  assign a_o = w1 ^ w2 ^ w3 ^ w4 ^ w5 ^ w6;
endmodule
