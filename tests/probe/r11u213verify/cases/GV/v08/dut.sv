// § genScopeClassVarListed206 (a class through a wildcard import, a typedef of a specialization, a same-named outer variable)
package p;
  class c #(int W = 1); logic [W-1:0] v; endclass
  typedef c #(3) c3_t;
endpackage
module v08 ();
  import p::*;
  c q;
  for (genvar i = 0; i < 1; i++) begin : g
    c q;
    c3_t t;
  end
endmodule
