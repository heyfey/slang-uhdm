// § lineDirectiveIgnored416
module top #(parameter N = 2) (input logic [N-1:0] x, output logic [N-1:0] y);
`line 1 "dut.sv" 1
  function automatic logic inv(logic v);
    return ~v;
  endfunction
  for (genvar i = 0; i < N; i++) begin : g
    assign y[i] = inv(x[i]);
  end
endmodule
