// § unitArrTd245
// a $unit fixed-array typedef on a child's port
typedef logic [3:0] arr_t [2];
module sub(input arr_t x, output logic [3:0] o);
  assign o = x[0] ^ x[1];
endmodule
module top(input logic [3:0] a, b, output logic [3:0] o);
  arr_t t;
  assign t[0] = a;
  assign t[1] = b;
  sub s(.x(t), .o(o));
endmodule
