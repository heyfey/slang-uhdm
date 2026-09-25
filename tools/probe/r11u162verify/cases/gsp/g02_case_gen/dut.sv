// § genScopeProcPsNamedByScope154
module rs #(parameter int M = 1) (input clk, input [3:0] x, output [3:0] o);
  case (M)
    1: begin : one
      reg [3:0] v;
      always @(posedge clk) v[1:0] <= x[3:2];
      assign o = v;
    end
    default: begin : dflt
      assign o = x;
    end
  endcase
endmodule
module top(input clk, input [3:0] x, output [3:0] o); rs r(clk, x, o); endmodule
