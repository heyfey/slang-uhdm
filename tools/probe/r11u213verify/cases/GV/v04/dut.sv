// § genScopeClassVarListed206 (initializers: new and null)
class c; int x; endclass
module v04 ();
  if (1) begin : g
    c q = new;
    c r = null;
    c s;
  end
endmodule
