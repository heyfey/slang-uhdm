// § pasteBlankLedStartWritten416
`define op_begin(OP) \
  if (!(k&UVM_NO``OP)) begin

module top;
  localparam int UVM_NOA = 1, UVM_NOBB = 2, UVM_NOCCC = 3, UVM_NODDDD = 4, UVM_NOEEEEE = 5, UVM_NOFFFFFF = 6, UVM_NOGGGGGGG = 7;
  int k, a;
  initial begin
    `op_begin(A) a = 1; end
    `op_begin(BB) a = 1; end
    `op_begin(CCC) a = 1; end
    `op_begin(DDDD) a = 1; end
    `op_begin(EEEEE) a = 1; end
    `op_begin(FFFFFF) a = 1; end
    `op_begin(GGGGGGG) a = 1; end
  end
endmodule
