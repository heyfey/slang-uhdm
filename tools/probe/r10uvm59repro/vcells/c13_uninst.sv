// VERIFIER CELL c13 — POSITION outside class scope: an UNINSTANTIATED module.
// slang suppresses lookup errors in uninstantiated code, so this is a second
// silent population for kind==Invalid.
module top59c13;
  initial begin
  end
endmodule
module unused59 (input logic clk);
  int i;
  initial begin
    i = nosuchpkg59::nosuchfn(1);
  end
endmodule
