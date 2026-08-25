// r10earl85 g1 — the head shape and the unary-fold grid, module scope.
module leaf85 #(parameter int AddrW = 10, parameter int WordsPerPage = 256) ();
  localparam int WordsBitWidth = $clog2(WordsPerPage);
  // u01: the HEAD shape verbatim: unsized 'h1 shifted, minus a sized 1'b1, negated.
  localparam logic[AddrW-1:0] u01 = ~(('h1 << WordsBitWidth) - 1'b1);
  // u02: same but the shifted literal is SIZED.
  localparam logic[AddrW-1:0] u02 = ~((32'h1 << WordsBitWidth) - 1'b1);
  // u03: ~ over a plain sized literal.
  localparam logic[AddrW-1:0] u03 = ~(32'd255);
  // u04: ~ over an unsized literal.
  localparam logic[AddrW-1:0] u04 = ~('h ff);
  // u05: ~ over a parameter ref.
  localparam logic[AddrW-1:0] u05 = ~WordsBitWidth;
  // u06: ~ over the folded shift-minus with the shift written the other way.
  localparam logic[AddrW-1:0] u06 = ~((1 << WordsBitWidth) - 1);
  // u07: no unary at all — the whole thing folds.
  localparam logic[AddrW-1:0] u07 = ('h1 << WordsBitWidth) - 1'b1;
  // u08: the INNER alone, unsized shift.
  localparam logic[AddrW-1:0] u08 = 'h1 << WordsBitWidth;
  // u09: unary minus over the same operand.
  localparam logic[AddrW-1:0] u09 = -(('h1 << WordsBitWidth) - 1'b1);
  // u10: logical not.
  localparam logic[AddrW-1:0] u10 = !(('h1 << WordsBitWidth) - 1'b1);
  // u11: reduction or.
  localparam logic[AddrW-1:0] u11 = |(('h1 << WordsBitWidth) - 1'b1);
  // u12: reduction and.
  localparam logic[AddrW-1:0] u12 = &(('h1 << WordsBitWidth) - 1'b1);
  // u13: reduction xor.
  localparam logic[AddrW-1:0] u13 = ^(('h1 << WordsBitWidth) - 1'b1);
  // u14: ~ over an unsized shift WITHOUT the -1.
  localparam logic[AddrW-1:0] u14 = ~('h1 << WordsBitWidth);
  // u15: int-declared, not logic-ranged.
  localparam int u15 = ~(('h1 << WordsBitWidth) - 1'b1);
  // u16: untyped.
  localparam u16 = ~(('h1 << WordsBitWidth) - 1'b1);
endmodule

module top85();
  leaf85 #(.AddrW(17), .WordsPerPage(256)) u_a ();
endmodule
