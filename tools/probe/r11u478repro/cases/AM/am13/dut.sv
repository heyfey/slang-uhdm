// § cloneHierArrElemMember478 (a member path two deep: only the first member binds)
package u;
  typedef struct { int k; bit [7:0] b; } in_t;
  typedef struct { int k; in_t s; } op_t;
  function automatic int f(int n);
    op_t acc[$]; int r;
    r = acc[0].s.b;
    return r;
  endfunction
endpackage
package a; import u::*; class A; function int g(); return f(1); endfunction endclass endpackage
module top; import a::*; A o; endmodule
