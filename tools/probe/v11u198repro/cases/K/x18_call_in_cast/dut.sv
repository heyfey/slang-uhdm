// § genCaCastRhsRefUnnamed198
module top (input logic s, input logic [3:0] b, output logic [2:0] y [2]);
  function automatic logic [3:0] fx(input logic [3:0] x); return x; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = 3'(fx(b) + b);
  end
endmodule
