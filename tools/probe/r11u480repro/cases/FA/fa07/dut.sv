// § fixArrLocalNamedAggElemTs480 (module function, anonymous struct)
module top;
  function int f(int n);
    struct { int k; int data; } acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
