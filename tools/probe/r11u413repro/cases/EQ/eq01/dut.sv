// § emptyConcatArrayVar413
module top;
  int q[$];
  initial begin
    q.push_back(2);
    q = {};
  end
endmodule
