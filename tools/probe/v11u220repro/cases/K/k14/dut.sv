// § strLitContLineSpan220
module top(output logic [63:0] o);
  localparam logic [63:0] L = "lp\
x";
  assign o = L;
endmodule
