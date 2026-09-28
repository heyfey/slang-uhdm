// (r11u191 N0215) an out-of-body class method and a pure virtual prototype with an operation default
virtual class B;
  pure virtual function int pv(int a, int b = a * 2);
endclass
class C extends B;
  extern function int pv(int a, int b = a * 2);
endclass
function int C::pv(int a, int b = a * 2);
  return a + b;
endfunction
module top; endmodule
