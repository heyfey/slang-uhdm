// § unique0IfIsUnique403
module top;
  function int f(int s);
    unique0 if (s == 0) return 1; else return 2;
  endfunction
  int y; initial y = f(1);
endmodule
