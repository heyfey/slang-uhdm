module v04(input logic [7:0] m, output logic [7:0] o);
  if (1) begin : g1
    if (1) begin : g2
      logic [7:0] x = 8'd5;
      logic [7:0] a = x;
    end
  end
  case (1) 1: begin : g3 logic [7:0] y = 8'd1; logic [7:0] z = y; end endcase
endmodule
