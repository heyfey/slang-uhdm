// § genBlockBitsKeepsSelect200
module top(input logic [15:0] x, output logic [31:0] z, output logic [31:0] z3);
  if (1) begin : g
    function automatic int fw(input logic [15:0] v);
      return $bits(v[3:0]);
    endfunction
    assign z = fw(x);
    always_comb z3 = $bits(x[2:0]) + 1;
  end
endmodule
