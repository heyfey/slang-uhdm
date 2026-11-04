// § netSigningTsSpan130
// case s05: `wire unsigned` with two declarators, no initializers
module top(output logic [7:0] o);
  wire unsigned [3:0] u, v;
  assign u = 4'd1;
  assign v = 4'd2;
  assign o = {u, v};
endmodule
