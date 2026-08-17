module b1_rgg1;
  // B1: while + compound-assign literal, function NOT constant-called
  function automatic int f_notcalled(int n);
    int i;
    i = 0;
    while (i < n) begin
      i += 1;
    end
    return i;
  endfunction
  // B2: same shape, function IS called in a localparam initializer
  function automatic int f_constcalled(int n);
    int j;
    j = 0;
    while (j < n) begin
      j += 1;
    end
    return j;
  endfunction
  localparam int P_B2 = f_constcalled(3);
  // B3: constant-called, compound assign with literal 7 (not 1)
  function automatic int f_seven(int n);
    int k;
    k = 0;
    while (k < n) begin
      k += 7;
    end
    return k;
  endfunction
  localparam int P_B3 = f_seven(20);
  // B4: constant-called, for-loop with compound assign literal
  function automatic int f_for(int n);
    int m;
    m = 0;
    for (int q = 0; q < n; ++q) begin
      m += 2;
    end
    return m;
  endfunction
  localparam int P_B4 = f_for(3);
  // B5: constant-called, plain (non-compound) literal assign in the loop
  function automatic int f_plain(int n);
    int r; int s;
    r = 0;
    while (r < n) begin
      s = 9;
      r = r + 1;
    end
    return s;
  endfunction
  localparam int P_B5 = f_plain(2);
  int o1, o2, o3, o4, o5;
  initial begin
    o1 = f_notcalled(2);
  end
endmodule
