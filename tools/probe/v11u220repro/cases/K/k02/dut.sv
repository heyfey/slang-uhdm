// § strLitContLineSpan220
module top(output logic [63:0] o);
  always_comb o = "ab\
cd";
endmodule
