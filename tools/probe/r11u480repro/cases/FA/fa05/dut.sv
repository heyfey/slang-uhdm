// § fixArrLocalNamedAggElemTs480 (module function, unpacked union typedef)
module top;
  typedef union { int k; int data; } un_t;
  function int f(int n);
    un_t acc[2];
    acc[0].k = n;
    return acc[0].data;
  endfunction
  int x;
  initial x = f(1);
endmodule
