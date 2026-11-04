// § foreachArrayPlaceholderFile140
class c;
  int q[$];
  int m[$][$];
  function void f();
    foreach (m[i, j]) q.push_back(m[i][j]);
    foreach (q[k]) q[k] = 0;
  endfunction
endclass
module top; endmodule
