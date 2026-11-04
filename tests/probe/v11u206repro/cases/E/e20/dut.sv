// § genScopeClassVarListed206
package pk;
  class c #(int W = 1);
  endclass
endpackage
import pk::*;
module e20;
  if (1) begin : g
    c #(4) q;
    c r;
  end
endmodule
