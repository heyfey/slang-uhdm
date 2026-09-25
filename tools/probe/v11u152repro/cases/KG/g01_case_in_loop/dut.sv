// § genCaseItemUnnamed152
module top(output logic [1:0] o);
  parameter int S = 1;
  for (genvar i = 0; i < 2; i++) begin : lp
    case (S)
      1: begin : tag
        wire w = 1'b1;
        assign o[i] = w;
      end
      default: begin : dflt
        assign o[i] = 1'b0;
      end
    endcase
  end
endmodule
