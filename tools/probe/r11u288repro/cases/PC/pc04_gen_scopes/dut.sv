// § parenCastReadsCastSyntax288 — for-, if- and case-generate continuous assignments, one and two levels, module typedef target
module top #(parameter int P = 1)(input logic [7:0] x, output logic [7:0] o[4], q);
  typedef logic [7:0] b_t;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = (b_t'(x)) + (int'(i));
    for (genvar j = 0; j < 1; j++) begin : h
      assign o[i+2] = (int'(x)) + (int'(j));
    end
  end
  if (P == 1) begin : gi
    assign q = (int'(x)) + 1;
  end
  case (P)
    2: begin : gc assign q = (byte'(x)); end
    default: ;
  endcase
endmodule
