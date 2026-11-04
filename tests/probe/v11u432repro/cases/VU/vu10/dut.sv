// § unitParamShadowDefBind432
localparam CF = 0;
module m #(parameter CF = 1)(input [3:0] a, output o);
  function automatic logic g(input [3:0] v);
    logic CF;
    CF = v[0];
    return CF;
  endfunction
  assign o = g(a) ^ a[CF];
endmodule
module top(input [3:0] a, output o);
  m #(.CF(2)) u(.a(a), .o(o));
endmodule
