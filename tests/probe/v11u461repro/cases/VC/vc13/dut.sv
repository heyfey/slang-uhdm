// § pkgImportUnionCloneHomeInst461
package p;
  typedef union packed { int x; int unsigned y; } u_t;
endpackage
package ap;
  import p::*;
  function automatic int f(u_t a);
    return a.x;
  endfunction
endpackage
module top;
  import ap::*;
endmodule
