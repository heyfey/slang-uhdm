// § insideSetParamFoldKeepsPa270
module sub #(parameter P = 1, parameter Q = 2)(input int w, output logic y);
  function automatic logic f(int v);
    return v inside {P, Q};
  endfunction
  assign y = f(w);
endmodule
module top(input int w, output logic y);
  sub #(.P(7)) u(.w(w), .y(y));
endmodule
