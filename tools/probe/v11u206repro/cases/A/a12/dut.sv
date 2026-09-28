// § tpCastUseBindsDefDefault206
module a12 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o, output t p);
  t [3:0] x;
  always_comb begin
    x[0] = s ? t'(1) : t'(0);
    x[1] = t'(s);
  end
  function automatic t f(input logic b);
    return b ? t'(2) : t'(1);
  endfunction
  assign o = x[0];
  assign p = f(s);
endmodule
