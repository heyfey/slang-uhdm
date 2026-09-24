module top (input logic [7:0][3:0] a, output logic [1:0] y [4]);
  for (genvar i = 0; i < 3; i++) begin : g
    localparam int unsigned L = i*2;
    assign y[i] = a[L+1][1:0];
  end
endmodule
