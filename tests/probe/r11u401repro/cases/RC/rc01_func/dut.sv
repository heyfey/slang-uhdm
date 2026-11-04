// § randCaseIsRandCaseStmt401
function int F();
  int a;
  randcase
    0 : a = 5;
    1 : a = 10;
  endcase
  return a;
endfunction
module top;
  int x;
  initial x = F();
endmodule
