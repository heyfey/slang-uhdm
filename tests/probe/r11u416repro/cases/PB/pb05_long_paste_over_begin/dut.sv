// § pasteBlankLedStartWritten416
`define op_begin(OP) \
  if (!(k&N``OP)) begin

module top;
  localparam int NLONGNAMEXYZ = 1, NLONGERNAMEXYZW = 2;
  int k, a;
  initial begin
    `op_begin(LONGNAMEXYZ) a = 1; end
    `op_begin(LONGERNAMEXYZW) a = 2; end
  end
endmodule
