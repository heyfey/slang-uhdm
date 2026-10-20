// § emptyConcatArrayVar413
module top;
  int q[$];
  logic [7:0] v;
  initial begin
    q = {1, 2};
    v = {4'h1, 4'h2};
  end
endmodule
