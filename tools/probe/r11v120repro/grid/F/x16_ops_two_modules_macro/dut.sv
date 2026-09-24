`define AND2(x, y) ((x) & (y))
module sub(input logic [3:0] a, output logic [1:0] o);
`ifndef SYNTHESIS
  // pragma translate_off
  initial $display("sub");
  // pragma translate_on
`endif
  assign o[0] = a[0] ^ a[1];
  assign o[1] = `AND2(a[2], a[3]);
endmodule
module top(input logic [3:0] a, input logic [3:0] b, output logic [7:0] o);
  sub u(.a(a), .o(o[1:0]));
  assign o[2] = a[2] | b[2];
  always_comb begin
    o[3] = a[3] & b[3];
    o[4] = a[0] ^ b[0];
  end
  assign o[7:5] = a[2:0] - b[2:0];
endmodule
