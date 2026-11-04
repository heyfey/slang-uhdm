// § parenCallWrittenArgs477
module top(output int z, output int y);
  int q[$];
  string s;
  initial begin z = (q.size()); y = (s.len()); end
endmodule
