// § unitArrTd245
// a size-form $unit fixed-array typedef on a child variable, the child instanced twice
typedef bit [1:0] pr_t [4];
module sub(input logic [1:0] a, output logic [1:0] o);
  pr_t t;
  assign t[0] = a;
  assign t[1] = a;
  assign t[2] = a;
  assign t[3] = a;
  assign o = t[a];
endmodule
module top(input logic [1:0] a, output logic [1:0] o1, o2);
  sub x(.a(a), .o(o1));
  sub y(.a(o1), .o(o2));
endmodule
