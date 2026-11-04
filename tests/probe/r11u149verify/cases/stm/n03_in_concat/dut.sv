// § streamOperandBraceSpan140
module dut(input logic [3:0] a, input logic [3:0] b, output logic [7:0] y);
  typedef logic [3:0] n_t;
  assign y = { n_t'( { <<  { a } } ), b };
endmodule
