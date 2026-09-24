// § defNetEndOnlyLoc130
module top;
  if (1) begin : g
    enum logic [1:0] {A, B, C} st;
    initial st = B;
  end
endmodule
