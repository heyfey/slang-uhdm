// § strLitContLineSpan220
module top(output logic [63:0] o);
  logic [63:0] w = "nd\
a";
  assign o = w;
endmodule
