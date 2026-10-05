// § unitPredefTd245
// a $unit int unsigned and a byte typedef on module variables
typedef int unsigned uu_t;
typedef byte by_t;
module top(input int unsigned i, output int unsigned o, output byte b);
  uu_t v;
  by_t w;
  assign w = i[7:0];
  assign v = i;
  assign o = v;
  assign b = w;
endmodule
