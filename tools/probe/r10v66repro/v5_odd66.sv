// r10v66 arm 5 — ODD ENCODINGS: X/Z members, expression-valued, localparam-
// valued, negative, typedef'd base, >32-bit, and an enum member read where the
// whole actual is already a constant expression.
package vpk5;
  localparam logic [3:0] LPV = 4'h9;
  typedef logic [5:0] w6_t;
  typedef enum logic [3:0] { XA = 4'bx010, ZA = 4'bz001 } x4_t;
  typedef enum logic [3:0] { EE = 4'h2 + 4'h1, LL = LPV } e4x_t;
  typedef enum int { NG = -5, NP = 12 } ni_t;
  typedef enum w6_t { TA = 6'h13, TB = 6'o21 } tw_t;
  typedef enum bit [63:0] { BIG = 64'hdeadbeef12345678 } b64_t;
endpackage

module vk5 (input logic [3:0] q1, input logic [3:0] q2, input logic [3:0] q3,
            input logic [3:0] q4, input logic [31:0] q5, input logic [5:0] q6,
            input logic [63:0] q7, input logic [7:0] q8);
endmodule

module vtop5;
  import vpk5::*;
  logic [255:0] bus;
  logic [63:0]  wide;
  vk5 u_o (.q1(bus[EE +: 4]),
           .q2(bus[LL -: 4]),
           .q3({2'b0, bus[TA] , bus[TB]}),
           .q4(4'(NP)),
           .q5(32'(NG)),
           .q6(TA | TB),
           .q7({BIG}),
           .q8({4'b0, XA}));
  logic [3:0] cz;
  assign cz = ZA;
endmodule
