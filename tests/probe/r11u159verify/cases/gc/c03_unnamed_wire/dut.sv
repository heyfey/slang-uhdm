// § genCaseItemUnnamed152
module top(output logic o);
  parameter int S = 0;
  case (S)
    0: begin
      wire w = 1'b1;
      assign o = w;
    end
    default: assign o = 1'b0;
  endcase
endmodule
