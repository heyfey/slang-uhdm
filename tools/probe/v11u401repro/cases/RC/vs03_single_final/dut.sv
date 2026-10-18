// § randCaseIsRandCaseStmt401
module top;
  int x;
  final randcase 1 : x = 1; endcase
  always @(x) randcase 3 : x = 2; 1 : ; endcase
endmodule
