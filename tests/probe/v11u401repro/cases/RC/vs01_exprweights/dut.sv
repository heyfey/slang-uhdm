// § randCaseIsRandCaseStmt401
module top;
  int a, x;
  initial randcase
    a + 1 : x = 1;
    2 : begin x = 2; end
    a : randcase 1: x = 3; 3: x = 4; endcase
  endcase
endmodule
