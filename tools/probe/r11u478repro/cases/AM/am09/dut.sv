// § cloneHierArrElemMember478 (a struct typedef of another package)
package v;
  typedef struct { int k; bit [63:0] data; } op_t;
endpackage
package u;
  import v::*;
  function automatic int f(int n);
    op_t acc[$]; int r;
    r = acc[0].data;
    return r;
  endfunction
endpackage
package a; import u::*; class A; function int g(); return f(1); endfunction endclass endpackage
module top; import a::*; A o; endmodule
