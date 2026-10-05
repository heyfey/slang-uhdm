// § unitTdLawS245
// a type parameter defaulting to a $unit vector typedef, overridden in one instance
typedef logic [3:0] nib_t;
typedef logic [7:0] byt_t;
module sub #(parameter type T = nib_t) (input T i, output T o);
  T x;
  assign x = i;
  assign o = x;
endmodule
module top(input logic [7:0] i, output logic [3:0] o1, output logic [7:0] o2);
  sub a(.i(i[3:0]), .o(o1));
  sub #(.T(byt_t)) b(.i(i), .o(o2));
endmodule
