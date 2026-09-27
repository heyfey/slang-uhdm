// § aliasOfTdSharedKeepsModName183
package p;
typedef logic signed [3:0] s_t;
typedef s_t a_t;
typedef struct packed { a_t x; a_t y; } two_t;
endpackage
module top import p::*; (input two_t i, output logic [3:0] o);
  assign o = i.x ^ i.y;
endmodule
