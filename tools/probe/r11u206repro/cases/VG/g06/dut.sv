// § genScopeClassVarListed206
package p;
  class c #(int W = 1);
  endclass
endpackage
module g06;
  if (1) begin : g
    if (1) begin : h
      p::c #(4) q;
      p::c r;
    end
  end
endmodule
