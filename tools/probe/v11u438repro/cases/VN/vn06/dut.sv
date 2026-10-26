// § ndaUnsizedRhsFreshLhs438
typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
module sub(input st_t [3:0] arr, output st_t y);
  wire st_t w = arr['h1];
  assign y = w;
endmodule
module top(input st_t [3:0] arr, output st_t y);
  sub u(.arr(arr), .y(y));
endmodule
