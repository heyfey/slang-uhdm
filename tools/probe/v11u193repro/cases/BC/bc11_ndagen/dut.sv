// § castOperandLeafElab193
module dut (input logic [3:0] a [2], output logic [7:0] o [2]);
  logic [3:0] r [2];
  assign r = a;
  for (genvar i = 0; i < 2; i++) begin : g
    wire [7:0] w = 8'(r[i]);
    assign o[i] = w;
  end
endmodule
