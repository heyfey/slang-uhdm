// § parenCallWrittenArgs477
package p;
  class c;
    extern function int g(int a);
    function int m(int a, int b = 7); return a + b; endfunction
  endclass
  function int c::g(int a);
    return (m(a)) + 1;
  endfunction
endpackage
module top;
  import p::*;
  c o;
  int z;
  initial begin o = new; z = (o.g(2)); end
endmodule
