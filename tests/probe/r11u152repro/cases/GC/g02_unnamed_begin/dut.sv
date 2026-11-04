// § genCaseItemUnnamed152
module GOOD();
endmodule
module top();
  parameter int P = 1;
  case (P)
    1: begin
      GOOD u2();
    end
    default: GOOD u3();
  endcase
endmodule
