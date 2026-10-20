// § pasteBlankLedStartWritten416
`define fld(OP) \
  case (k) \
    K_``OP: if (k == NO_``OP) begin \
      a = 1; \
    end \
  endcase

module top;
  localparam int K_COMPARE = 1, NO_COMPARE = 2, K_PRINT = 3, NO_PRINT = 4;
  int k, a;
  initial begin
    `fld(COMPARE)
    `fld(PRINT)
  end
endmodule
