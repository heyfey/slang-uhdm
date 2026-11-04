// § paramIdxPartSelWholeSpan131
module sub #(parameter int W = 1) ();
endmodule
module top ();
  function automatic int f(logic [7:0] x); return x + 1; endfunction
  localparam logic [31:0] A = 32'hdeadbeef;
  sub #(.W(f(A[8 +: 8]))) u();
endmodule
