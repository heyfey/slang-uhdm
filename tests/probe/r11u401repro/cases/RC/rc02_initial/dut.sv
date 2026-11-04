// § randCaseIsRandCaseStmt401
module top;
  int x;
  initial begin
    randcase
      3 : x = 1;
      x + 1 : x = 2;
      1 : begin x = 3; end
    endcase
  end
endmodule
