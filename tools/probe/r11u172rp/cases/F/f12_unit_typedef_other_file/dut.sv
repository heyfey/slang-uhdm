module top (input logic [2:0] i, output logic o);
  function automatic logic f(s_t v);
    return v.y;
  endfunction
  s_t t;
  assign t = i;
  assign o = f(t);
endmodule
