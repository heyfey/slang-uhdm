// § emptyConcatArrayVar413
module top;
  string sq[$];
  initial begin
    sq.push_back("a");
    sq = {};
  end
endmodule
