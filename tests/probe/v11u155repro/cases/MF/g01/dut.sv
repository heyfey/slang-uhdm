// § modAggTfArgLastWriter155
module top(input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
  function automatic logic [1:0] f (s_t op); return op.a; endfunction
  s_t arr [2];
  assign arr[0] = i; assign arr[1] = i;
  assign o = {f(arr[0]), f(arr[1])};
endmodule
