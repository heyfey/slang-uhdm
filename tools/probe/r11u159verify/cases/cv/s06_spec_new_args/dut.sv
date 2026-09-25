// § classVarInitSpan152
class C #(type T = int);
  T x;
  function new(T v);
    x = v;
  endfunction
endclass
module top ();
  C#(int) c1 = new(5), c2 = new(6);
endmodule
