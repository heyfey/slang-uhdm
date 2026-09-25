// § classVarInitSpan152
class C;
  int x;
  function new(int a); x = a; endfunction
endclass
module top ();
  C c1 = new(5);
endmodule
