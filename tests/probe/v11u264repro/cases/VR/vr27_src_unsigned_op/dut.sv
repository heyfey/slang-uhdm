// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam logic [3:0] U = 4'd3;
  localparam int A = U + 1;
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
