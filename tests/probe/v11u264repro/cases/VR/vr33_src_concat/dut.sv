// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam int A = {16'd1, 16'd2};
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
