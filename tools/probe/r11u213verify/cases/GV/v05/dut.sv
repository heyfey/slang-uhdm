// § genScopeClassVarListed206 § genScopeClassVarSpecAtName206 (type arguments; the module instantiated twice)
class c #(type T = int); T v; endclass
module leaf #(parameter int N = 1) ();
  if (N > 0) begin : g
    c #(byte) q;
    c #(logic [N:0]) r;
  end
endmodule
module v05 ();
  leaf #(2) a ();
  leaf #(5) b ();
endmodule
