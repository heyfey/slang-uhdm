// § ppOutputCol166
`define SIG(n) n``_s
module top(input logic a_s, input logic b, output logic y);
  assign y = `SIG(a) & b;
endmodule
