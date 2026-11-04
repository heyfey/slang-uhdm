// § ppOutputCol166
`define E
module top(input logic a, output logic y, output logic z);
  `E assign y = a;
  `E `E assign z = ~a;
endmodule
