// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
  typedef logic [W-1:0] w_t;
endpackage
package q;
  typedef struct packed {
    logic [$bits(p::w_t)-1:0] a;
    logic [p::W/2-1:0] b;
  } s_t;
  typedef struct packed { s_t in; logic [p::W:1] c; } o_t;
endpackage
module top(output logic o);
  q::o_t x;
  assign x = '0;
  assign o = x.in.a[0];
endmodule
