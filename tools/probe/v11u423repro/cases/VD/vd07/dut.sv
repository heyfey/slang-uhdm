// § decUnszElabRespellKeepsM1_423
module top(output int y);
  parameter T = 'd12;
  localparam U = T + 1;
  function automatic int f();
    localparam K = 'd3;
    return K;
  endfunction
  assign y = f() + U;
endmodule
