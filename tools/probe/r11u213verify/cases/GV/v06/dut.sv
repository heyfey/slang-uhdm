// § genScopeClassVarListed206 § genScopeClassVarSpecAtName206 (residue check: a named-value specialization; an empty one)
class c #(int W = 4); logic [W-1:0] v; endclass
module v06 ();
  if (1) begin : g
    c #(.W(8)) q;
    c #() r;
  end
endmodule
