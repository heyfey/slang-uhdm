// § insideSetParamFoldKeepsPa270
module leaf #(parameter int P = 1) (input int w, output logic o);
  function automatic logic f(int x); return x inside {P, P + 1}; endfunction
  assign o = f(w);
endmodule
module mid #(parameter int P = 2) (input int w, output logic o);
  leaf #(.P(P * 2)) l (.w(w), .o(o));
endmodule
module top (input int w, output logic o);
  mid #(.P(3)) m (.w(w), .o(o));
endmodule
