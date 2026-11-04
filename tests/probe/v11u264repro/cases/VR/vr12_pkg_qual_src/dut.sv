// § elabParamRefSignedTsUnlocated264
package pk;
  localparam int PA = 6;
  localparam int PB = PA;
endpackage
module sub (output logic [31:0] o);
  localparam int A = pk::PA;
  localparam int B = A;
  localparam int C = pk::PB;
  assign o = A + B + C;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
