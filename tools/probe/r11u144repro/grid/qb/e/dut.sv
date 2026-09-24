// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  typedef struct packed {
    logic [p::W:0] d;
    logic v;
  } s_t;
endpackage
module top(output logic o);
  q::s_t x;
  assign x = '0;
  assign o = x.v;
endmodule
