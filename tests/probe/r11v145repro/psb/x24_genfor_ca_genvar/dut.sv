// § psBoundBareRefByBase145
module dut(input logic [31:0] a, output logic [3:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int H = i*4+3;
    assign o[i] = a[H:i*4];
  end
endmodule
