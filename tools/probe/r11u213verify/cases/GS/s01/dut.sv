// § genScopeClassVarSpecAtName206 (spacing and line breaks inside the specialization; two arguments)
class c #(int W = 4, type T = int); logic [W-1:0] v; T t; endclass
module s01 ();
  if (1) begin : g
    c#( 3 ) a;
    c
      #(5, byte) b;
    c #(2) d, e;
  end
endmodule
