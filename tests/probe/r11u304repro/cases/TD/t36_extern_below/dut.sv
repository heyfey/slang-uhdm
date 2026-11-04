// § tfBodyTypedefForcesBegin304
package p;
  class c;
    int m;
    extern function int g(int a);
    function int u(); return g(1); endfunction
  endclass
  function int c::g(int a);
    typedef bit [2:0] s_t;
    return a + m;
  endfunction
endpackage
module top; endmodule
