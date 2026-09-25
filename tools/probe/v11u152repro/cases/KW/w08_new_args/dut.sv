// § classVarInitSpan152
class C;
  int x;
  function new(int v); x = v; endfunction
endclass
module top ();
  C c1 = new(4);
endmodule
