// § strLitShiftNeedsBacktick220
module top(output logic [63:0] o, output logic [63:0] q);
  always_comb begin
    o = "a\\b\n";
    q = "c\td";
  end
endmodule
