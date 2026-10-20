// § pasteBlankLedStartWritten416
`define op_begin(OP, FLAG) \
UVM_``OP: \
  if (!((FLAG)&UVM_NO``OP)) begin

`define op_end(OP) \
  end

`define fld(ARG,FLAG=UVM_DEFAULT) \
  case (k) \
    `op_begin(COPY,FLAG) \
      ARG = 1; \
    `op_end(COPY) \
    `op_begin(COMPARE,FLAG) \
      ARG = 2; \
    `op_end(COMPARE) \
    `op_begin(UNPACK,FLAG) \
      ARG = 3; \
    `op_end(UNPACK) \
    `op_begin(PRINT,FLAG) \
      ARG = 4; \
    `op_end(PRINT) \
    `op_begin(SET,FLAG) \
      ARG = 5; \
    `op_end(SET) \
  endcase

module top;
  localparam int UVM_COPY = 1, UVM_COMPARE = 2, UVM_UNPACK = 3, UVM_PRINT = 4, UVM_SET = 5;
  localparam int UVM_NOCOPY = 1, UVM_NOCOMPARE = 2, UVM_NOUNPACK = 4, UVM_NOPRINT = 8, UVM_NOSET = 16;
  localparam int UVM_DEFAULT = 0;
  int k, a;
  initial begin
    `fld(a)
  end
endmodule
