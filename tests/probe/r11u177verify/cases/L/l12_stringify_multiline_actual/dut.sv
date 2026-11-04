// § ppOutputLine166 § ppOutputCol166
`define SHOW(x, y) $display(`"x`", y)
module top(input logic a, output logic y);
  initial `SHOW(val, a +
                a); assign y = a;
endmodule
