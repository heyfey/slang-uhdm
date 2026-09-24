module top (input logic [15:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      localparam int unsigned L = 2**(i+1)-1+j*2;
      assign y[i*2+j] = a[L+1];
    end
  end
endmodule
