// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  typedef struct packed {
    logic [p::W-1:0] d;
    logic v;
  } in_t;
  typedef struct packed {
    in_t i;
    logic [p::W-1:0] e;
  } s_t;
  typedef union packed {
    logic [p::W:0] a;
    logic [p::W:0] b;
  } u_t;
endpackage
module top(output logic o);
  q::s_t x;
  q::u_t y;
  assign x = '0;
  assign y = '0;
  assign o = x.i.v ^ y.a[0];
endmodule
