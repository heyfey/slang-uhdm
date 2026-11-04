// § ppStrEndNotTokStart251 (the produced end lands on an lvalue start of the next statement)
`define D(F) begin s = `"F`"; t = s; end
module top;
  string s, t;
  initial `D(abcde)
endmodule
