// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam int A = int'(2.0);
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
