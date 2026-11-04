// § randCaseIsRandCaseStmt401
module top;
  function int f(int w);
    int r;
    randcase w : r = 1; 10 - w : r = 0; endcase
    return r;
  endfunction
  int y;
  initial y = f(3);
endmodule
