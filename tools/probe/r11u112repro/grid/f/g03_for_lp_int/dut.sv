module top (input logic [7:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int L = i*2;
    assign y[i] = a[L+1];
  end
endmodule
