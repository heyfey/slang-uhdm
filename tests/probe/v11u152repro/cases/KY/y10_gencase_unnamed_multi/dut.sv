// § genCaseItemUnnamed152
module top(output logic o, output logic p);
  parameter int S = 1;
  case (S)
    0, 1: begin
      wire w = 1'b1;
      assign o = w;
      assign p = w;
    end
    default: begin
      assign o = 1'b0;
      assign p = 1'b0;
    end
  endcase
endmodule
