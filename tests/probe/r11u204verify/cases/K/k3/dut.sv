// § genCaCastRhsRefUnnamed198: a size cast of a concatenation with a part select in a case-generate's for-generate, and a cast of a replication in an if-generate
module top #(parameter int M = 1) (input logic s, input logic [2:0] q [2], output logic [2:0] y [2], output logic [5:0] z);
  case (M)
    1: begin : c1
      for (genvar i = 0; i < 2; i++) begin : g
        assign y[i] = 3'({s, q[i][1:0]});
      end
    end
    default: begin : cd end
  endcase
  if (M > 0) begin : gi
    assign z[5:0] = 6'({3{s, 1'b0}});
  end
endmodule
