// § unitArrTd245
// a $unit fixed array typedef whose element is another $unit typedef, and a 2-D one
typedef logic [3:0] nib_t;
typedef nib_t na_t[2];
typedef int i2_t[2][3];
module top;
  na_t a;
  i2_t b;
endmodule
