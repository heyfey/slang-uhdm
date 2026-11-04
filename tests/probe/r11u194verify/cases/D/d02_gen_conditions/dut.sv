// § synLitUnderscoreDropped186: separators in a generate-for bound (1_0), an if-generate condition (1_000_000), a generate case item and a 65-bit decimal in an if-generate comparison
module top #(parameter longint P = 1_000_000) (output logic [9:0] o, output logic b, output logic c);
  for (genvar g = 0; g < 1_0; g++) begin : gl
    assign o[g] = 1'b0;
  end
  if (P == 1_000_000) begin : gi
    assign b = 1'b1;
  end else begin : ge
    assign b = 1'b0;
  end
  case (P)
    1_000_000: begin : gc assign c = 1'b1; end
    default: begin : gd assign c = 1'b0; end
  endcase
endmodule
