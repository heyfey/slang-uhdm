// § caPlainLhsUnsizedClone438
typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
module sub(input st_t [3:0] arr, output st_t y);
  assign y = arr['h2];
endmodule
module top(input st_t [3:0] arr, output st_t y);
  sub u(.arr(arr), .y(y));
endmodule
