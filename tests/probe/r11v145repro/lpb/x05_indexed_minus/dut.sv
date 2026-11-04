// § lpPaCopyBoundOwnerName145
module dut(input logic [31:0] a, output logic [3:0] o);
  localparam int H = 11;
  if (1) begin : g
    assign o = a[H-:4];
  end
endmodule
