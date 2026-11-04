// § genCaseItemUnnamed152
module top(output logic o);
  parameter int S = 3;
  localparam int K = 3;
  case (S)
    K: begin : k
      logic v;
      assign v = 1'b1;
      assign o = v;
    end
    K+1: begin : k1
      assign o = 1'b0;
    end
    default: assign o = 1'b0;
  endcase
endmodule
