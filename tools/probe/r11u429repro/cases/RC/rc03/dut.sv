// § unitClsCastPkgEnumTdTopListing429
package p;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
  function void g(e_t r); endfunction
  class pb; endclass
endpackage
import p::*;
module top;
  function automatic e_t f(int x);
    return e_t'(x & 3);
  endfunction
  e_t q;
  initial q = f(1);
endmodule
