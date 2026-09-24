module top(input logic [3:0] a, input logic [3:0] b, output logic [7:0] o);
  assign o[0] = a[0] & b[0];
  // synopsys translate_off
  `define W 3
  initial $display("sim");
  // synopsys translate_on
`ifdef W
  assign o[1] = a[1] | b[1];
`else
  assign o[1] = a[1] & b[1];
`endif
  assign o[7:2] = {a, b[1:0]} + 6'd1;
endmodule
