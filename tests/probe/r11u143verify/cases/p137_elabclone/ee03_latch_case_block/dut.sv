// § elabCloneFullNameUnstored137
// case ee03: always_latch with a case whose item holds a named block, in a sub-module
module sub(input logic en, input logic [1:0] s, input logic [3:0] d, output logic [3:0] q);
  always_latch begin
    if (en) begin
      case (s)
        2'd0: begin : c0 q = d; end
        default: begin : cd q = ~d; end
      endcase
    end
  end
endmodule
module top(input logic en, input logic [1:0] s, input logic [3:0] d, output logic [3:0] q);
  sub u(.en(en), .s(s), .d(d), .q(q));
endmodule
