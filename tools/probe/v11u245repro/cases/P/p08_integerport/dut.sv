// § unitTdLawS245
// a $unit integer typedef on a child port and a child variable, positional and named
typedef integer ig_t;
module sub(input ig_t a, output ig_t b);
  ig_t t;
  assign t = a;
  assign b = t;
endmodule
module top(input integer i, output integer o1, o2);
  sub x(i, o1);
  sub y(.a(o1), .b(o2));
endmodule
