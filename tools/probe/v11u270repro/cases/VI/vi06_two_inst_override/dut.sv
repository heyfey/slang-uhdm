// § insideSetParamFoldKeepsPa270
module sub #(parameter int P = 1, parameter int Q = 2) (input int w, output logic o);
  function automatic logic f(int x);
    return x inside {P, Q};
  endfunction
  always_comb o = f(w);
endmodule
module top (input int w, output logic a, b);
  sub #(.P(5)) u1 (.w(w), .o(a));
  sub #(.Q(9)) u2 (.w(w), .o(b));
endmodule
