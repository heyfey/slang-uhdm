module m1 import pa::*; (input logic [4:0] i, output logic o);
  function automatic logic g(s_t v);
    return v.y;
  endfunction
  assign o = g(i);
endmodule
