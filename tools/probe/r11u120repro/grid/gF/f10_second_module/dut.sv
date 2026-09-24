module sub(input logic a, output logic b);
  assign b = ~a;
endmodule
`ifndef SYNTHESIS
// pragma translate_off
// pragma translate_on
`endif
module top(input logic a, output logic [7:0] o);
  sub u (.a(a), .b(o[1]));
  assign o[0] = a;
  assign o[7:2] = '0;
endmodule
