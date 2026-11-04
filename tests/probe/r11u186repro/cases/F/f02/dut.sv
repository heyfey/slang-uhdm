// § foreachAssocLocalSharesDeclTs183 (module function, int index)
module top;
  function automatic int f();
    byte m[int];
    int n;
    foreach (m[k]) n += k;
    return n;
  endfunction
endmodule
