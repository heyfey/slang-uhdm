// § sysArgUnaryWholeSpan140
module top(input logic [3:0] x, output logic o);
  always_comb begin
    case ($signed(-x))
      4'sd1: o = 1'b1;
      default: o = 1'b0;
    endcase
  end
endmodule
