// § unitParamShadowDefBind432
localparam CF = 0;
module m(input [3:0] a, output o);
  localparam CF = 1;
  function automatic logic g(input [3:0] x);
    return x[CF];
  endfunction
  assign o = g(a);
endmodule
