// § elabParamRefSignedTsUnlocated264
package pk;
  parameter int NE = 12;
endpackage
module sub(output logic [7:0] o);
  localparam int NE = pk::NE;
  localparam int X = NE;
  assign o = NE + X;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
