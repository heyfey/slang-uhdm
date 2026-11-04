// § cloneHierArrElemMember478 (a packed array of a packed struct)
package u;
  typedef struct packed { int k; bit [31:0] data; } op_t;
  function automatic int f(int n);
    op_t [1:0] acc; int r;
    r = acc[0].data;
    return r;
  endfunction
endpackage
package a; import u::*; class A; function int g(); return f(1); endfunction endclass endpackage
module top; import a::*; A o; endmodule
