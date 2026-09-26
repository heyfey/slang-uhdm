module top;
  function automatic int g(int n);
    int k;
    k = 0;
    do begin
      k += 2;
    end
    while (k < n);
    return k;
  endfunction
  int r;
  initial r = g(5);
endmodule
