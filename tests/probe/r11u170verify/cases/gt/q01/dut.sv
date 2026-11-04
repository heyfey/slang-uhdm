// § genTgtLhsLeafOwnName157
module top #(parameter int M = 1) (input logic a, output logic o, output logic o2);
  case (M)
    1: begin : C wire x; end
    default: begin : C wire x; end
  endcase
  if (1) begin : G
    if (1) begin : H wire y; end
  end
  assign C.x = a;
  assign G.H.y = ~a;
  assign o = C.x;
  assign o2 = G.H.y;
endmodule
