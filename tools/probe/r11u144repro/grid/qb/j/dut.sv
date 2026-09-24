// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  typedef struct packed {
    logic [p::W-1:0] d;
    logic v;
  } s_t;
  typedef struct packed {
    s_t a;
    logic [p::W-1:0] e;
  } u_t;
endpackage
module top(output logic o);
  q::u_t x;
  assign x = '0;
  assign o = x.a.v;
endmodule
