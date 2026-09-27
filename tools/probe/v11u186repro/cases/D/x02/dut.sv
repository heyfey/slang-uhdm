// § synLitUnderscoreDropped186 (if-generate condition, generate case item, genvar init)
module top #(parameter int P = 12)(output logic [31:0] o);
  if (P > 1_0) begin : g1
    assign o[0] = 1'b1;
  end else begin : g2
    assign o[0] = 1'b0;
  end
  case (P)
    1_2: begin : c1 assign o[1] = 1'b1; end
    default: begin : c2 assign o[1] = 1'b0; end
  endcase
  for (genvar g = 1_0; g < 1_2; g++) begin : gl
    assign o[g] = 1'b1;
  end
endmodule
