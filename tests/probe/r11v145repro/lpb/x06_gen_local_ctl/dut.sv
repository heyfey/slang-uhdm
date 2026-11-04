// § lpPaCopyBoundOwnerName145
module dut(input logic [31:0] a, output logic [7:0] o);
  if (1) begin : g
    localparam int L = 4;
    assign o = a[L+7:L];
  end
endmodule
