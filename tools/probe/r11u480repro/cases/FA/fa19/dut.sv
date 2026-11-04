// § fixArrLocalNamedAggElemTs480 (interface function)
interface ifc;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
endinterface
module top;
  ifc u();
  int x;
  initial x = u.f(1);
endmodule
