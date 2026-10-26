// § genCaConstRhsWhole433
module top (output [31:0] z0, z1);
  for (genvar i = 0; i < 2; i++) begin: g
    if (i == 0) begin: a
      assign z0 = i + 5;
    end else begin: b
      assign z1 = i * 3;
    end
  end
endmodule
