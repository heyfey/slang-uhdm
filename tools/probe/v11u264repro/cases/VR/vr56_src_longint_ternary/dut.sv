// § elabParamRefSignedTsUnlocated264
module sub (output logic [31:0] o);
  localparam longint L = 3;
  localparam int I = 2;
  localparam int B = 1 ? L : I;
  localparam int C = 0 ? L : I;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
