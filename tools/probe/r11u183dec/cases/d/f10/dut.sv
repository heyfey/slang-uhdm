module top;
  function automatic int f();
    int n;
    int m[string];
    foreach (m[k]) n = n + 1;
    return n;
  endfunction
endmodule
