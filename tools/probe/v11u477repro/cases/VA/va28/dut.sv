// § caAddLeafIntMint477
module top(output logic [7:0] z [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign z[i] = i + 8'd1;
  end
endmodule
