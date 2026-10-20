// § emptyConcatArrayVar413
module top;
  string s[$];
  int d[];
  initial begin
    s = {};
    d = {};
    s = {"a"};
  end
endmodule
