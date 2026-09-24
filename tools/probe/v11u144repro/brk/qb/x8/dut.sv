// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  function automatic logic [p::W-1:0] f(input logic [p::W-1:0] a);
    return a;
  endfunction
endpackage
module top(input logic [7:0] a, output logic [7:0] o);
  assign o = q::f(a);
endmodule
