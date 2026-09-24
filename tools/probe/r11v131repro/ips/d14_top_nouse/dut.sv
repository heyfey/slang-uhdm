// § paramIdxPartSelWholeSpan131
module top ();
  localparam logic [31:0] A = 32'hdeadbeef;
  localparam logic [7:0] P = A[8 +: 8];
endmodule
