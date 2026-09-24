// § paramIdxPartSelWholeSpan131
module top ();
  localparam logic [31:0] A = 32'hdeadbeef;
  parameter int W = 0;
  localparam logic [7:0] P = (W > 0) ? 8'h0 : A[8 +: 8];
endmodule
