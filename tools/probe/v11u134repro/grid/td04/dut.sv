// § defNetTypedefEndWrite134
module top(input logic c, output logic o);
  typedef struct { logic a; logic [2:0] b; } us_t;
  us_t arr [2];
  assign arr[0].a = c;
  assign arr[1].a = ~c;
  assign o = arr[0].a ^ arr[1].a;
endmodule
