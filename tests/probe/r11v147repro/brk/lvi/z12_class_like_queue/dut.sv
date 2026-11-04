// § lvIdxBitSelAtIndex147
module top (input logic [2:0] b, output int o);
  int q [$];
  int m [int];
  initial begin
    q.push_back(1);
    q[b[0]] = 5;
    m[b[1]] = 7;
    o = q[0] + m[1];
  end
endmodule
