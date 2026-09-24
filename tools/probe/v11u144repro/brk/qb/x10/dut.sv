// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package r;
  localparam int V = 3;
endpackage
package q;
  typedef struct packed {
    logic [p::W-1:0] d;
    logic [r::V-1:0] c;
    logic [p::W-r::V:0] m;
  } s_t;
  typedef s_t [1:0] arr_t;
endpackage
module top(output logic o);
  q::arr_t x;
  assign x = '0;
  assign o = x[1].c[0];
endmodule
