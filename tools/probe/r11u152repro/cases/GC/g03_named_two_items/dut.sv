// § genCaseItemUnnamed152
module GOOD();
endmodule
module top();
  parameter int P = 1;
  parameter int Q = 1;
  case (P)
    0: begin : ga
      GOOD u1();
    end
    Q: begin : gb
      GOOD u2();
      GOOD u4();
    end
    default: GOOD u3();
  endcase
endmodule
