// § lpPaCopyBoundOwnerName145
module dut(input logic [31:0] a, output logic [3:0] o [2]);
  localparam int L = 4;
  for (genvar i = 0; i < 2; i++) begin : gl
    if (1) begin : gi
      assign o[i] = a[L+3:L];
    end
  end
endmodule
