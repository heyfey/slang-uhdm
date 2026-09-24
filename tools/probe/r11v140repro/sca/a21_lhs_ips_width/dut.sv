// § sysArgUnaryConstSelToken140v
module top(input logic [7:0] a, output logic [31:0] o);
  always_comb begin
    o = '0;
    o[0 +: $bits(~a)] = a;
  end
endmodule
