// § strLitPpEscIdShift224 (a net declaration assignment list: the second net after the literal)
module top(output logic [63:0] o, output logic [63:0] p);
  wire [63:0] w = "a\nb` c", w2 = 64'd1;
  assign o = w;
  assign p = w2;
endmodule
