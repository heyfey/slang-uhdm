// § stdRandomizeFuncCall413
class C;
  rand int x;
  int y;
  extern function void f();
endclass
function void C::f();
  void'(randomize(x));
  y = x;
endfunction
module top;
endmodule
