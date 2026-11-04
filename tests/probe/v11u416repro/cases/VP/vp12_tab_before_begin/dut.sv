// § pasteBlankLedStartWritten416
`define ob(OP) \
  if (!(k&UVM_NO``OP))	begin

module top;
  localparam int UVM_NOCOMPARE = 2, UVM_NOPRINT = 8;
  int k, a;
  initial begin
    `ob(COMPARE) a = 1; end
    `ob(PRINT) a = 2; end
  end
endmodule
