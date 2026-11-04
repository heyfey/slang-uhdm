// § ppOutputCol166
`define A a_long_name
`define B b
module top(input logic a_long_name, input logic b, output logic y);
  assign y = `A + `B + `A;
endmodule
