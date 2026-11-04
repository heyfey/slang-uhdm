// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam byte Y = 3;
  localparam B = Y;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
