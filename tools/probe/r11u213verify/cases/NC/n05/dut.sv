// § namedUnlinkedWrittenOrder207 (a static extern method with defaults called by name from a module and from another class before its body)
package p;
  class F;
    extern static function int sf(int a, int b = 1, int c = 2);
  endclass
  class G;
    function int g(int x);
      return F::sf(.c(x), .a(1));
    endfunction
  endclass
  function int F::sf(int a, int b = 1, int c = 2);
    return a + b + c;
  endfunction
endpackage
module top (input int x, output int o);
  always_comb o = p::F::sf(.c(x), .a(2));
endmodule
