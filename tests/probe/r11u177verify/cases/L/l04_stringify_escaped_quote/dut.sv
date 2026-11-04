// § ppOutputCol166 § ppOutputLine166
`define STR(x, y) `"x \" y`"
module top(input logic a, output logic y);
  initial $display(`STR(hello, q), a); initial $display(`STR(a,
    b));
  assign y = a;
endmodule
