// § pasteBlankLedStartWritten416
`define op_begin(OP) \
  if (!(k&UVM_NOTHING``OP)) begin

module top;
  localparam int UVM_NOTHINGA = 1, UVM_NOTHINGBB = 2;
  int k, a;
  initial begin
    `op_begin(A) a = 1; end
    `op_begin(BB) a = 1; end
  end
endmodule
