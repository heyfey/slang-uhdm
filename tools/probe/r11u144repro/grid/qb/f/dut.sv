// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  typedef struct packed {
    logic [p::W-1:0] d;
    logic v;
  } s_t;
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
