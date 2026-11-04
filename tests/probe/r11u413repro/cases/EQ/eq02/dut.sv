// § emptyConcatArrayVar413
module top;
  int d[];
  initial begin
    d = new[2];
    d = {};
  end
endmodule
