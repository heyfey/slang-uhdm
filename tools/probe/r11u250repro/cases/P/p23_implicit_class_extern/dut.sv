// § pkgArrTdBindCopies250
package p;
  typedef logic [3:0] b_t[2];
  typedef int q_t[$];
  class base #(int N = 2);
    int m;
  endclass
  virtual class c extends base #($size(b_t));
    extern function int sz(q_t a);
    pure virtual function void nop();
  endclass
  function int c::sz(q_t a);
    return a.size();
  endfunction
endpackage
module top(input logic [3:0] i, output logic [3:0] o);
  import p::*;
  b_t r;
  assign r[0] = i;
  assign w = r[0][1];
  assign o = r[0];
endmodule
