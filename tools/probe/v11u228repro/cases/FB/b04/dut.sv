// § sizeBitNetIsVar228 — a bit port in a generate block's net declaration and an unpacked bit port
module dut (input bit [3:0][2:0] pp, input bit [1:0] pu [3], output logic [7:0] o1, o2);
  if (1) begin : g
    wire [7:0] w = $size(pp);
  end
  wire [7:0] w2 = $size(pu, 2);
  assign o1 = g.w; assign o2 = w2;
endmodule
