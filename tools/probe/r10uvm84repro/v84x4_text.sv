// v84x4 — TEXT EDGES of the written-chain predicate: trivia between the tokens,
// and a macro-produced chain.
`define X84 this.h.fld
`define CALL84 this.h.arr.size()
module v84x4;
  class in4x;
    int fld;
    int arr[$];
  endclass
  class c4x;
    in4x h;
    int  n;
    function void f();
      n = this.h.fld;              // L14 plain
      n = this . h . fld;          // L15 SPACES around the dots
      n = this./*c*/h.fld;         // L16 block comment after the first dot
      n = this.h/*c*/.fld;         // L17 block comment before the second dot
      n = `X84;                    // L18 macro-expanded member chain
      n = `CALL84;                 // L19 macro-expanded builtin call
      n = this.
          h.fld;                   // L21 newline inside the chain
      n = this.h.arr.size();       // L22 plain call control
      n = this.h .arr .size();     // L23 spaces before the dots, call
    endfunction
  endclass
endmodule
