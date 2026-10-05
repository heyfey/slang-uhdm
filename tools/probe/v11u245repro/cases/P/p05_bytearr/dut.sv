// § unitTdLawS245
// an unpacked array variable of a $unit byte typedef
typedef byte by_t;
module top(input logic a, input byte d, output byte q);
  by_t m [2];
  assign m[0] = d;
  assign m[1] = ~d;
  assign q = m[a];
endmodule
