// § genCaseItemUnnamed152
module top(output logic o);
  parameter int S = 2;
  if (1) begin : gi
    case (S)
      1, 2: begin : tag
        wire w = 1'b1;
        assign o = w;
      end
      default: assign o = 1'b0;
    endcase
  end
endmodule
