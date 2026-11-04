// § fixArrLocalNamedAggElemTs480 (typedef declared in the base class, used in a derived class method)
package p;
  class B;
    typedef struct { int k; int d; } op_t;
  endclass
  class D extends B;
    function int f(int n);
      op_t acc[2];
      acc[0].k = n;
      return acc[0].k;
    endfunction
  endclass
endpackage
module top;
  import p::*;
  D d;
endmodule
