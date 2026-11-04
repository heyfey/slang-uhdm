module top(input logic a, output logic [3:0] o);
  assign o[0] = a; // synopsys translate_on
  assign o[1] = ~a;
  always_comb o[2] = a ^ o[1];
  assign o[3] = a;
endmodule
