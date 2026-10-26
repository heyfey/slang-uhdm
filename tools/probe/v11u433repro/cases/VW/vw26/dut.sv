// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z, v, u);
  localparam L = 2*3;
  localparam M = 10 - 3;
  localparam N = 3000000000;
  logic [3:0] x;
  if (W <= 4) begin: g
    assign y = L + 1;
    assign z = M + 1;
    assign v = N + 1;
    assign u = $bits(x) + L;
  end
endmodule
