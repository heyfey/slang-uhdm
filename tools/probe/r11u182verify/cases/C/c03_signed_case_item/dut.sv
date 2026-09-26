// § sysSignNameSpanSyntax172
module dut #(parameter int P = 1) (input logic signed [3:0] a, b, output logic o, output logic [1:0] q);
  always_comb begin
    case (a)
      $signed(b): o = 1'b1;
      $signed(4'sd2): o = 1'b0;
      default: o = 1'bx;
    endcase
  end
  case ($signed(P))
    1: begin : c1
      assign q = $unsigned(a[1:0]);
    end
    default: begin : c2
      assign q = 2'b00;
    end
  endcase
endmodule
