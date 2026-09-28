// § aliasOfTdSharedKeepsModName183: a three-step alias chain across two packages used in a port struct and a local variable of two modules
package p;
  typedef logic [3:0] n_t;
  typedef n_t m_t;
endpackage
package q;
  import p::*;
  typedef m_t k_t;
  typedef struct packed { k_t a; k_t b; } pr_t;
endpackage
module sub (input q::pr_t x, output logic [3:0] y);
  q::k_t t;
  assign t = x.a;
  assign y = t;
endmodule
module top (input q::pr_t x, output logic [3:0] y);
  sub u (.x(x), .y(y));
endmodule
