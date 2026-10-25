// § unitClsCastPkgEnumTdTopListing429
package p;
  parameter RB = 28;
  typedef bit [RB+3:0] ft;
  typedef enum ft { A = 'h1000000, B = 0 } e_t;
  function void g(e_t r); endfunction
  class pb; e_t m; virtual function void vf(int x); endfunction endclass
endpackage
import p::*;
class C;
  task t(int x);
    e_t v;
    fork
      v = e_t'(x);
    join
  endtask
endclass
module top; C c = new; endmodule
