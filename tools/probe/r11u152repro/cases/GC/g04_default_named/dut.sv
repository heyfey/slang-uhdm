// § genCaseItemUnnamed152
module GOOD();
endmodule
module top();
  parameter int P = 7;
  case (P)
    0: GOOD u1();
    default: begin : gd
      GOOD u3();
    end
  endcase
endmodule
