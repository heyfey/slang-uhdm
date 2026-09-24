// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
module top(output logic o);
  typedef struct packed {
    logic [p::W-1:0] d;
    logic v;
  } s_t;
  s_t x;
  assign x = '0;
  assign o = x.v;
endmodule
