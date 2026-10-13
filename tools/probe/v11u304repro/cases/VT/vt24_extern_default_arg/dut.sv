// § tfBodyTypedefForcesBegin304
package p;
  class c;
    extern function int g(int a = 3);
  endclass
  function int c::g(int a = 3);
    typedef logic [2:0] n_t;
    return n_t'(a);
  endfunction
endpackage
module top; endmodule
