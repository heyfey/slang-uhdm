// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam integer A = 7;
  localparam integer B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
