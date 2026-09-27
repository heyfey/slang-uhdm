// § aliasOfTdSharedKeepsModName183 (two importers)
package p;
typedef logic [5:0] b_t;
typedef b_t c_t;
typedef struct packed { c_t f; } s_t;
endpackage
module m import p::*; (input s_t i, output logic [5:0] o);
  assign o = i.f;
endmodule
module top import p::*; (input s_t i, output logic [5:0] o);
  m u(.i(i), .o(o));
endmodule
