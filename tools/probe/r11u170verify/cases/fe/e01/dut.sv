// § foreachArrPathVarForm157
typedef struct { int arr[4]; int q[3]; } s_t;
module top;
  s_t s; int sum;
  always_comb begin
    sum = 0;
    foreach (s.arr[i]) sum += s.arr[i];
  end
endmodule
