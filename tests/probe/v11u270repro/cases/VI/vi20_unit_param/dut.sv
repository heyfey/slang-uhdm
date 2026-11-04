// § insideSetParamFoldKeepsPa270
parameter int UA = 1;
localparam int UB = 2;
module top (input int w, output logic o);
  function automatic logic f(int x); return x inside {UA, UB}; endfunction
  always_comb o = f(w);
endmodule
