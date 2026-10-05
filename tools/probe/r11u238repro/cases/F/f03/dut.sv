// § foreachClassPropStringTsShared238
module top;
  function automatic int cnt(string s);
    int d = 0;
    foreach (s[i]) if (s[i] == ".") d++;
    return d;
  endfunction
  string m = "a.b";
  int k;
  initial begin
    k = 0;
    foreach (m[j]) k++;
  end
endmodule
