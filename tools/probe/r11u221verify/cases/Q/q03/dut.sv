// § genScopeRangeQueryFold216 — $high of a two-dimensional packed variable (outer range), $increment (not a bound query: control) in a gen-case
module dut #(parameter int SEL = 1) (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  logic [3:0][9:2] m;
  logic [0:5] a;
  case (SEL)
    0: begin : c0 assign o1 = 8'd0; end
    1: begin : c1
      assign o1 = $high(m);
      assign o2 = $increment(a);
      assign o3 = $low(m);
    end
    default: begin : cd assign o1 = 8'd1; end
  endcase
endmodule
