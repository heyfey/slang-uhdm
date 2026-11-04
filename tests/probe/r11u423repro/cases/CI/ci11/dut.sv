// § caseItemPkgFoldTsOps423 (control: unchanged, already golden)
module top;
  parameter int A = 16;
  function void f(int x);
    case (x)
      A: x = 0;
    endcase
  endfunction
endmodule
