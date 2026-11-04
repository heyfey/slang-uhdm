// § fixArrLocalNamedAggElemTs480 (class in another package using an imported struct)
package a;
  typedef struct { int k; int data; } op_t;
endpackage
package b;
  import a::*;
  class C;
    function int f(int n);
      op_t acc[2];
      acc[0].k = n;
      return acc[0].k;
    endfunction
  endclass
endpackage
module top;
  import b::*;
  C c;
endmodule
