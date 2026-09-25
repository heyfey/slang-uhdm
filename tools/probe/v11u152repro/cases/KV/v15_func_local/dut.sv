// § classVarInitSpan152
class C #(type T=int);
  T x;
endclass
module top ();
  function automatic int f();
    C#(longint) c1 = new;
    return 0;
  endfunction
  int y = f();
endmodule
