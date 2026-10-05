// § unitTdLawS245
// $unit typedefs on ports (kept on the listing) beside body variables (copied)
typedef logic [3:0] nib_t;
typedef int ui_t;
module child(input nib_t a, output nib_t b, input ui_t n);
  nib_t t;
  ui_t k;
  assign t = a;
  assign b = t;
endmodule
module top(input nib_t x, output nib_t y);
  child c(.a(x), .b(y), .n(3));
endmodule
