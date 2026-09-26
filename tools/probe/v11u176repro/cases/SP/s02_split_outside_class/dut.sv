// § tfArgDefTopSplit176
package p;
  typedef enum {A, B, C} e_t;
  function automatic int f(e_t g);
    return int'(g);
  endfunction
endpackage
package r;
  import p::*;
  class k;
    function void m(e_t x);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  import r::*;
  k o; int v;
  initial begin o = new; o.m(B); v = f(C); end
endmodule
