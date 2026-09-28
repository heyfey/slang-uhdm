// § genCaUnclonedFoldOwner198: a child module's case-generate assigning a replication inside $unsigned and a unary inside $signed, the child instantiated twice under a generate
package pk; parameter int unsigned W = 3; endpackage
module ch import pk::*; #(parameter int M = 1) (input logic s, output logic [7:0] y [2]);
  case (M)
    1: begin : c1
      assign y[0] = $unsigned({W{1'b1}});
      assign y[1] = $signed(-W);
    end
    default: begin : cd
      assign y[0] = {W, s};
    end
  endcase
endmodule
module top (input logic s, output logic [7:0] y [2], output logic [7:0] z [2]);
  if (1) begin : t
    ch u1 (.s(s), .y(y));
    ch #(2) u2 (.s(s), .y(z));
  end
endmodule
