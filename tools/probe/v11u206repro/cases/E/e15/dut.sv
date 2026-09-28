// § genScopeClassVarListed206
class c;
  function new(int w); endfunction
endclass
module e15 #(parameter int W = 3);
  if (W > 1) begin : g
    c q = new(W);
  end
endmodule
