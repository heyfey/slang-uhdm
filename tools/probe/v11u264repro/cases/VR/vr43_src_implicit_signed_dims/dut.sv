// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam signed [3:0] A = 5;
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
