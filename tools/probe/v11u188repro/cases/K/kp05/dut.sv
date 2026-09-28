// § tpFormalIncludeOrder188
package p;
  class c #(type T = int);
    T p;
    function void pre(T y);
      p = y;
    endfunction
    extern function void set(T x);
  endclass
  `include "k05_impl.svh"
endpackage
module top; endmodule
