// § lpPaCopyBoundOwnerName145
module dut(input logic [31:0] a, input logic [2:0] i, output logic [7:0] o);
  localparam int L = 4;
  if (1) begin : g
    assign o = a[7:L];
  end
endmodule
