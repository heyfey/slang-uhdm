// § pkgTsRefObjChainName134
package p;
  localparam int K = 3;
  function automatic logic [K-1:0] f(input logic [K-1:0] a);
    logic [K:0] t;
    t = {1'b0, a};
    return t[K-1:0];
  endfunction
endpackage
module top(input logic [2:0] i, output logic [2:0] o);
  assign o = p::f(i);
endmodule
