// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  typedef struct packed {
    logic [p::W-1:0] d;
    logic [p::W-1:p::W/2] h;
  } s_t;
  typedef s_t [1:0] a_t;
endpackage
module top(output logic o);
  q::a_t x;
  assign x = '0;
  assign o = x[1].d[0];
endmodule
