// § gateGenvarDivShiftFold411
module top;
  wire [7:0] a, y;
  for (genvar i = 0; i < 2; i++) begin : g
    tran t1 (a[i<<2], y[6/2+i]);
  end
endmodule
