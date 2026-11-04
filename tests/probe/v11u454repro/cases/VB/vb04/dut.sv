// § unpackedDimBasedLitKept454
module top;
  function automatic int f(input int a [2'd1:0]);
    int t [3'd2:0];
    t[0] = a[0];
    return t[0];
  endfunction
  task automatic tk();
    logic [1:0] l [1'b1:1'b0];
    l[0] = 0;
  endtask
  int r;
  int ai [2];
  initial r = f(ai);
endmodule
