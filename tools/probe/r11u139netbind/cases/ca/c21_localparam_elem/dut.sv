module top(output a);
  localparam logic [3:0] L = 4'hA;
  assign a = L[1];
endmodule
