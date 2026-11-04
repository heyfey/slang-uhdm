// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  typedef int my_t;
  localparam my_t A = 6;
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
