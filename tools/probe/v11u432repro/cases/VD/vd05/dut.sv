// § unitParamSizeDimWide432
parameter D = 5;
module m(input clk);
  function automatic int f();
    int loc [D];
    return loc[0];
  endfunction
  int r = f();
  logic [3:0] two [D][D];
endmodule
