// § doWhileMacroCondEnd181 — the condition written through an object-like macro (v11u178 dw/w01 line 8)
`define C (i < 5)
module top;
  int i, j;
  initial begin
    do j++; while `C;
    do begin j--; i++; end while `C;
  end
endmodule
