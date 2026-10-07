// § ctorRetVarSiblingSpan277
package p;
  class pc #(int N = 2, type T = int);
    T v;
    extern function new(input T a, output int b);
  endclass
  function pc::new(input T a, output int b);
    v = a; b = N;
  endfunction
  class dd extends pc #(4, byte);
    function new(input byte a);
      int b;
      super.new(a, b);
    endfunction
  endclass
endpackage
module top;
  p::pc #(3, shortint) a;
  p::dd d;
endmodule
