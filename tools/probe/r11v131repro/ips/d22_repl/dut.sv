// § paramIdxPartSelWholeSpan131
module top ();
  localparam logic [31:0] A = 32'hdeadbeef;
  localparam logic [15:0] P = {2{A[8 +: 8]}};
endmodule
