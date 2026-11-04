// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  logic [5:0] r;
  localparam int A = $bits(r);
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
