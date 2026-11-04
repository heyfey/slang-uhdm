// § cloneHierArrElemMember478 (control: the home package itself, no clone)
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  function automatic int f(int n);
    op_t acc[$]; int r;
    r = acc[0].data;
    return r;
  endfunction
endpackage
module top; import u::*; int x = f(1); endmodule
