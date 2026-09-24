// § paramIdxPartSelWholeSpan131
module sub #(parameter logic [7:0] W = 0) ();
endmodule
module top ();
  localparam logic [31:0] A = 32'h01020304;
  sub #(.W({A[4 +: 4], A[0 +: 4]})) u();
endmodule
