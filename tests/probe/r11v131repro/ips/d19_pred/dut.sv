// § paramIdxPartSelWholeSpan131
module top ();
  localparam logic [31:0] A = 32'hdeadbeef;
  localparam int P = (A[8 +: 8] > 0) ? 5 : 6;
endmodule
