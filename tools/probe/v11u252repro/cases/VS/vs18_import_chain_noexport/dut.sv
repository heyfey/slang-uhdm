// § memReadHomePkgKey252v
package p;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2, c : 3};
  localparam integer X = D.a;
endpackage
package q;
  import p::*;
  localparam integer QX = X + D.b;
endpackage
module top import q::*; (output int o);
  assign o = 2;
endmodule
