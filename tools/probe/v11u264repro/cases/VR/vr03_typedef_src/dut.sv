// § elabParamRefSignedTsUnlocated264
typedef int my_int_t;
module sub (output logic [31:0] o);
  localparam my_int_t A = 6;
  localparam int B = A;
  localparam bit signed [7:0] S = 8'sd4;
  localparam int C = S;
  localparam my_int_t D = B;
  assign o = B + C + D;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
