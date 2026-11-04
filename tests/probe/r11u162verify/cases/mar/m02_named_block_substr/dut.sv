// § builtinMethodArgNamedByPath154
module top;
  string s = "abcdef";
  string u;
  int i = 1, j = 3;
  initial begin : nb
    u = s.substr(i, j);
  end
endmodule
