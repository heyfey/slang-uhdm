// § foreachArrayPlaceholderFile140
package pack;
  function automatic int f(int q[$]);
    int s = 0;
    foreach (q[i]) s += q[i];
    return s;
  endfunction
endpackage
