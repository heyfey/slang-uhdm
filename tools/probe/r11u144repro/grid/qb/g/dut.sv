// § pkgTsForeignQualRefUnstored144
package q;
  localparam int W = 8;
  typedef struct packed {
    logic [q::W-1:0] d;
    logic v;
  } s_t;
endpackage
module top(output logic o);
  q::s_t x;
  assign x = '0;
  assign o = x.v;
endmodule
