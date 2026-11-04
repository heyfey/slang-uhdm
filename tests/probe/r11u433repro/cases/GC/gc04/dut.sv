// § genCaConstRhsWhole433
module top #(parameter W = 2) (output [31:0] y, z, output signed [7:0] s);
  if (W > 1) begin: g
    localparam L = 3;
    assign y = L + W;
    assign z = 4'b1010 + 1;
    assign s = W - 5;
  end
endmodule
