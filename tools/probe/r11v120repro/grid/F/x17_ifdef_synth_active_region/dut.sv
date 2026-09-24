module top(input logic [3:0] a, input logic [3:0] b, output logic [7:0] o);
`ifdef SYNTHESIS
  // synthesis translate_off
  initial $display("never");
  // synthesis translate_on
`else
  initial $display("sim");
`endif
  assign o[0] = a[0] & b[0];
  assign o[1] = a[1] | b[1];
  assign o[7:2] = {a, b[1:0]} + 6'd1;
endmodule
