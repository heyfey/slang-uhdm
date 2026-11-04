// § lpPaCopyBoundOwnerName145
module dut(input logic [31:0] a, output logic [31:0] o);
  localparam int L = 4;
  if (1) begin : g
    assign o[7:0] = a[11:L];
  end
endmodule
