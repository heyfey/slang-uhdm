// § emptyConcatArrayVar413
module top;
  int q[$];
  int p[$][$];
  initial begin
    p.push_back({});
    q = {};
  end
endmodule
