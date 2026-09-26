// § genElseIfGateArrayPath176
module dut #(parameter P = 2) (input [1:0] a, b, output [1:0] c);
  if (P == 1) begin
    assign c = a;
  end else if (P > 1) begin
    case (P)
      2: begin
        or g1 [1:0] (c, a, b);
      end
      default: assign c = b;
    endcase
  end
endmodule
