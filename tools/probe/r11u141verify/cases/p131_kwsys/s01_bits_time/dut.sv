// § sysCallKwTypeArgNameSpan131
// case s01: $bits of time and integer as parameter defaults
module sub #(parameter int P = $bits(time), parameter int Q = $bits(integer)) (output logic [7:0] o);
  assign o = P + Q;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
