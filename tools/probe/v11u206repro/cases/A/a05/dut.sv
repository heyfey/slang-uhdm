// § tpCastUseBindsDefDefault206
module a05 #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic [1:0] s, output t o);
  t [3:0] x;
  for (genvar i = 0; i < 2; i++) begin : g
    function automatic t pick(input logic b);
      return b ? t'(3) : t'(1);
    endfunction
    assign x[i] = pick(s[i]);
  end
  assign o = x[0] ^ x[1];
endmodule
