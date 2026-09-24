module dut #(parameter type idx_t = logic [1:0]) (input logic [3:0] v, output logic [7:0] y [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    function automatic idx_t f(input logic [3:0] x);
      return idx_t'({x[k], x[k+1]} + 1'b1);
    endfunction
    assign y[k] = 8'(f(v));
  end
endmodule
