// § netSigningTsSpan130
// case s03: a signed net inside a named generate block
module top(output logic [3:0] o);
  if (1) begin : g
    wire signed [3:0] s = 4'sd5;
  end
  assign o = g.s;
endmodule
