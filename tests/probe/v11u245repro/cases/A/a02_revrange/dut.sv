// § unitArrTd245
// a $unit fixed-array typedef with a descending range and a size form beside it
typedef int ia_t [2:0];
typedef int sa_t [3];
module top(input int i, output int o);
  ia_t x;
  sa_t y;
  assign x[0] = i;
  assign x[1] = 0;
  assign x[2] = 0;
  assign y[2] = x[0];
  assign y[0] = 0;
  assign y[1] = 0;
  assign o = y[2];
endmodule
