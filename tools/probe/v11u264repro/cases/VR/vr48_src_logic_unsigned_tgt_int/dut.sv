// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam logic [7:0] A = 8'd9;
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
