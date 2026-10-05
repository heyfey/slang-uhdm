// § hoistPoolSourceOrder240: a parameterized class's out-of-body method and a static method, with a specialization in a bound
package hp;
  class zp #(int N = 2);
    int w;
    extern function int f();
    extern static function int s();
  endclass
  function int zp::f();
    return w + N;
  endfunction
  function int zp::s();
    return 1;
  endfunction
  class ap;
    int w;
    extern function int g();
  endclass
  function int ap::g();
    return w;
  endfunction
endpackage
module top;
  import hp::*;
  logic [zp#(3)::s():0] v;
  initial $display("x");
endmodule
