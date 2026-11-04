// § pasteBlankLedStartWritten416
`define ob(OP, FLAG) \
  if (!((FLAG)&UVM_NO``OP)) begin

module top;
  localparam int UVM_NOCOMPARE = 2, UVM_NOPRINT = 8, UVM_DEFAULT = 0, UVM_ALL_ON = 1;
  int a;
  initial begin
    `ob(COMPARE, UVM_DEFAULT | UVM_ALL_ON) a = 1; end
    `ob(PRINT, UVM_ALL_ON) a = 2; end
  end
endmodule
