// § insideSetParamFoldKeepsPa270
module top;
  parameter A = 3;
  localparam B = 4;
  function automatic void auto(int w);
    if (w inside {A, B}) w = 0;
  endfunction
endmodule
