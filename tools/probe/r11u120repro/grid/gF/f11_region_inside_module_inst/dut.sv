module leaf(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic a, output logic [7:0] o);
  // synthesis translate_off
  leaf l (.a(a), .b(o[1]));
  // synthesis translate_on
  assign o[0] = a;
  assign o[7:1] = '0;
endmodule
