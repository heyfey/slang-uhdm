module top (input logic [7:0] a, output logic [3:0] y);
  for (genvar i = 1; i < 5; i++) begin : g
    localparam int unsigned L = i*2;
    assign y[i-1] = a[L-1];
  end
endmodule
