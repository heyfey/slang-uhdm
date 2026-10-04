// § tfArgImportCloneFollowsIn231 — two classes, two out-of-body definitions
package p;
  typedef enum {A0, A1, A2} e_t;
  class c1;
    extern function void f(e_t x);
  endclass
  class c2;
    extern task t(int n, e_t y);
  endclass
  function void c1::f(e_t x);
  endfunction
  task c2::t(int n, e_t y);
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
