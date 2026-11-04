// § genCaConstRhsWhole433
module top (output [31:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    logic [i+2:0] q;
    if (i == 1) begin: h
      assign y = $bits(q);
    end
  end
endmodule
