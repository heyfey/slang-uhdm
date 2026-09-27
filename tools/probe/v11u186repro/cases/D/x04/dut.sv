// § synLitUnderscoreDropped186 (a wide if-generate condition constant)
module top #(parameter longint P = 5)(output logic o);
  if (P < 100_000_000_000_000_000_000) begin : g1
    assign o = 1'b1;
  end else begin : g2
    assign o = 1'b0;
  end
endmodule
