// § sysCallKwTypeArgNameSpan131
// case s02: $bits(int) written through a macro
`define BI $bits(int)
module sub #(parameter int P = `BI) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
