// § genNetDeclAssignLhsShared164 — a gen-case scope net declaration from a hierarchical path
module top #(parameter P = 1) (output wire o);
  if (1) begin : A
    wire x;
  end
  case (P)
    1: begin : C
      wire z = A.x;
    end
    default: begin : D
      wire z = 1'b0;
    end
  endcase
  assign o = C.z;
endmodule
