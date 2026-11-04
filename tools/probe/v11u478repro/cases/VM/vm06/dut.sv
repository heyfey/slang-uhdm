// § cloneHierArrElemMember478 (the array is a formal)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t arr_t [2];
  function automatic int f(arr_t acc);
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  class A; function int g(); arr_t x; return f(x); endfunction endclass
endpackage
module top; import a::*; A o; endmodule
