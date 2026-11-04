// § fixArrLocalNamedAggElemTs480 (foreach over the local array)
module top;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[4];
    int s;
    s = 0;
    foreach (acc[i]) begin
      acc[i].k = n + i;
      s += acc[i].k;
    end
    return s;
  endfunction
  int x;
  initial x = f(1);
endmodule
