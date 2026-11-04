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
    logic [2*p::W-1:0] f;
  } s_t;
endpackage
module top(output logic o);
  q::s_t x;
  assign x = '0;
  assign o = x.i.v ^ x.e[1];
endmodule
