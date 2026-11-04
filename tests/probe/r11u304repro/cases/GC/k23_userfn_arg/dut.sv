// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  function automatic logic [1:0] f(logic [1:0] x); return x; endfunction
  if (1) begin : g
    assign y = f(idx_t'(a));
  end
endmodule
