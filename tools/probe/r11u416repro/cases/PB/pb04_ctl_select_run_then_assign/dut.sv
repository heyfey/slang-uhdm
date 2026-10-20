// § pasteBlankLedStartWritten416
`define SETA(n) arr_``n[1] = 1'b1;
module top;
  logic [3:0] arr_abc, arr_abcdefg;
  initial begin
    `SETA(abc)
    `SETA(abcdefg)
  end
endmodule
