// § macroConnInRange166
`define BIT(s, i) s[i]
module sub(input logic a, input logic b, output logic y);
  assign y = a ^ b;
endmodule
module top(input logic [3:0] v, output logic y);
  sub u(.a(`BIT(v, 1)), .b(`BIT(v,
                               2)), .y(y));
endmodule
