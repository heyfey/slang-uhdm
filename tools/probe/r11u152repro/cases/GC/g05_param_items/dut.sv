// § genCaseItemUnnamed152
module GOOD();
endmodule
module top();
  parameter int A = 0;
  parameter int B = 1;
  parameter int P = 1;
  case (P)
    A: GOOD u1();
    B: GOOD u2();
    default: GOOD u3();
  endcase
endmodule
