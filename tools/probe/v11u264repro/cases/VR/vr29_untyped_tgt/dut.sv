// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam int A = 5;
  localparam B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
