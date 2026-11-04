// § tfBodyTypedefForcesBegin304
package p;
  function automatic int g(); return 1; endfunction
  function automatic void f();
    typedef int n_t;
    void'(g());
  endfunction
endpackage
module top; endmodule
