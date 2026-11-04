// § lpPaCopyBoundOwnerName145
module dut #(parameter int BW = 32) (input logic [31:0] a, output logic [29:0] o);
  localparam int L = $clog2(BW) - 3;
  if (1) begin : g
    assign o = a[31:L];
  end
endmodule
