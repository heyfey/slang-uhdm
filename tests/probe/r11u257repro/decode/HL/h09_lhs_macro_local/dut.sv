// § selChainElemShapeIsSyntactic147 (decode only, ground A: Rggen d #27671, a local struct member on the left side inside a macro body; ExprEmit)
`define conn(S, LSB, WIDTH) \
  assign  S.read_data[LSB+:WIDTH] = x;
module m; typedef struct packed { logic [7:0] read_data; } s_t; s_t sv; logic [3:0] x;
  `conn(sv, 0, 4)
endmodule
module top; m u(); endmodule
