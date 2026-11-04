// § tfBodyTypedefForcesBegin304
package p;
  class c;
    int m;
    extern function void g(int a);
  endclass
  function void c::g(int a);
    typedef bit [2:0] s_t;
    m = a;
  endfunction
endpackage
module top; endmodule
