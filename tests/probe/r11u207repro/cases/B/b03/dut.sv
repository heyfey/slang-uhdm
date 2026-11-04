// § bitSelMethodCallIdxSpan207: a string method (len) and a queue method (size) as the index of an rvalue select
module top(output int o, output byte b);
  string s = "abc";
  int q[$];
  int arr[16];
  initial begin
    o = arr[s.len()];
    o = arr[q.size() - 1] + arr[q.size()];
    b = s[s.len() - 1];
  end
endmodule
