// § tfArgOutsideClassOrder216 — two own classes (name order), an own task, and two outside class methods in two packages
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class Zc;
    function void f(e_t x); endfunction
  endclass
  class Ac;
    task t(input e_t x2); endtask
  endclass
  task automatic g(input e_t y); endtask
endpackage
package q;
  import p::*;
  class M;
    function void h(e_t z); endfunction
  endclass
endpackage
package r;
  import p::*;
  class N;
    virtual function string h2(e_t z2, int k); return ""; endfunction
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
