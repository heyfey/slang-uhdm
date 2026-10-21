// § defGenLpSysArgBitSelAtIndex424
module top #(parameter logic [7:0] P = 8'hA5) (output int o [3]);
  for (genvar i = 0; i < 3; i++) begin : rof
    localparam int A = $signed(P[i+1]);
    assign o[i] = A;
  end
endmodule
