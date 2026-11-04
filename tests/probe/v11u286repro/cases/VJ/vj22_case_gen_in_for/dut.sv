// § foldIntTsSignedKwTrim286
module top #(parameter int signed P = 3);
  logic [63:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    case (i)
      0: begin : c0 assign o[i] = P; end
      default: begin : cd assign o[i] = P; end
    endcase
  end
endmodule
