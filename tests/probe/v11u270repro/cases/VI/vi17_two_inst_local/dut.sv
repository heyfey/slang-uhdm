// § insideSetParamFoldKeepsPa270
module sub (input int w, output logic o);
  localparam int Q = 4;
  localparam int R = 6;
  function automatic logic f(int x);
    return x inside {Q, R};
  endfunction
  always_comb o = f(w);
endmodule
module top (input int w, output logic a, b);
  sub u1 (.w(w), .o(a));
  sub u2 (.w(w), .o(b));
endmodule
