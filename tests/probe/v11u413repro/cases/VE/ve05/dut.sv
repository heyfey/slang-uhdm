// § emptyConcatArrayVar413
module top;
  int d[];
  initial begin
    d = new[3];
    d = {};
  end
endmodule
