// § lineMacroAfterDirectivePlus1_425
module top(output int y);
    `line 30 "dut.sv" 0
  function automatic int f();
    return `__LINE__;
  endfunction
  assign y = f();
endmodule
