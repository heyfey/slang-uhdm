// § deferredAssertItemDropped406
module top #(parameter M = 1) (input logic a, output logic o);
  case (M)
    0: begin : z assign o = 1'b0; end
    1: begin : one assert final (a); assign o = a; end
  endcase
endmodule
