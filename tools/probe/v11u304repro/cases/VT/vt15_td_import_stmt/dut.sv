// § tfBodyTypedefIsItem304
package q; int z; endpackage
package p;
  function automatic int f(int a);
    typedef int n_t;
    n_t v = a;
    return v;
  endfunction
endpackage
module top; endmodule
