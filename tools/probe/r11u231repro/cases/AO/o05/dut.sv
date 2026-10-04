// § tfArgImportCloneFollowsIn231 — the importer is a module and a package
package p;
  typedef enum {A0, A1, A2} e_t;
  class c1;
    extern function void f(e_t x);
  endclass
  function void c1::f(e_t x);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  e_t s;
endmodule
