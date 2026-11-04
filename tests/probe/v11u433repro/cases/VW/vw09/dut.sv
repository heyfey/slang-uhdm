// § genCaConstRhsWhole433
module top #(parameter logic [3:0] W = 4'd2) ();
  logic [7:0] y, z;
  if (W <= 4) begin: g
    assign y = W + 1;
    assign z = W - 4'd1;
  end
endmodule
