// § insideSetParamFoldKeepsPa270
module top (input int w, output logic o, p);
  localparam int ARR [2] = '{1, 2};
  parameter int S = 4;
  function automatic logic f(int x);
    return x inside {ARR, S};
  endfunction
  always_comb o = f(w);
  always_comb p = w inside {S, [ARR[0]:ARR[1]]};
endmodule
