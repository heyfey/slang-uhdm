// § lpPaCopyBoundOwnerName145
module dut(input logic [31:0] a, output logic [7:0] o [2]);
  localparam int L = 4;
  for (genvar i = 0; i < 2; i++) begin : g
    if (1) begin : h
      assign o[i] = a[L+7:L];
    end
  end
endmodule
