// § lpPaCopyBoundOwnerName145
module dut(input logic [31:0] a, output logic [4:0] o);
  localparam int L = 4;
  if (1) begin : g
    assign o = a[L:0];
  end
endmodule
