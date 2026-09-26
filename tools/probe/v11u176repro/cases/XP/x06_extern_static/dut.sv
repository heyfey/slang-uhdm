// § externProtoFormalsFromPrototype175
package p;
  class k;
    extern static function int f(int a,
                                 int b);
  endclass
  function int k::f(int a, int b);
    return a * b;
  endfunction
endpackage
module top;
  import p::*;
  int r;
  initial r = k::f(2, 3);
endmodule
