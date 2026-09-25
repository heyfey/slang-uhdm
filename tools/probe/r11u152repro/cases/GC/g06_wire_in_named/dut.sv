// § genCaseItemUnnamed152
module top(output logic o);
  parameter int P = 1;
  case (P)
    1: begin : gw
      wire w = 1'b1;
      assign o = w;
    end
    default: assign o = 1'b0;
  endcase
endmodule
