module top(input logic a, output logic [7:0] o);
  assign o[0] = a;
  // pragma translate_on
  assign o[1] = ~a;
  assign o[2] = a;
  assign o[7:3] = '0;
endmodule
