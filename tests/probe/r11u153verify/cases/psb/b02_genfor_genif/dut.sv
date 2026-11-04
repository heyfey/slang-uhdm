// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : gl
    if (i >= 0) begin : gi
      localparam int H = 3;
      localparam int L = 0;
      assign o[i] = a[H:L];
    end
  end
endmodule
