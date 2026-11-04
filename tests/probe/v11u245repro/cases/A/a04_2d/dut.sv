// § unitArrTd245
// a two-dimensional $unit fixed-array typedef in the size form
typedef int a2_t [2][3];
module top(input int i, output int o);
  a2_t m;
  assign m[1][2] = i;
  assign o = m[1][2];
endmodule
