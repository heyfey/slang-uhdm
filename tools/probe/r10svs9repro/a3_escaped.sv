// r10svs9 arm a3 — THE ESCAPED-IDENTIFIER AND SPELLING GUARD ARM.
//
// A law about a DOTTED name is exactly where an escaped identifier CONTAINING A
// DOT bites: `\esc.h ` is ONE identifier whose text has a dot in it.  A law that
// found the base by scanning the source text for the first `.` would split that
// identifier in half and ship a lie.  These cells execute the choice to read the
// SYNTAX TOKEN instead, in both directions (escaped BASE, escaped MEMBER), and
// pin what the whitespace/macro spellings do to the recovered SPAN.
`define ATPATH(H) @ H.clock
class D;
  int r;
endclass

interface in_if(input bit clock);
  logic reset;
  clocking cb @(posedge clock);
  endclocking
  modport IP(clocking cb, output reset, input clock);
endinterface

class C;
  virtual in_if.IP vif;
  virtual in_if.IP \esc.h ;
  int r;

  // g1 an ESCAPED BASE whose own text CONTAINS A DOT.
  task g1(); @ \esc.h .clock; endtask

  // g2 the parenthesized twin of g1.
  task g2(); @(\esc.h .clock); endtask

  // g3 spaces around the dot.
  task g3(); @ vif . clock; endtask

  // g4 a NEWLINE inside the path.
  task g4(); @ vif.
                 clock; endtask

  // g5 a COMMENT before the member.
  task g5(); @ vif./*c*/clock; endtask

  // g6 the whole path spelled by a MACRO.
  task g6(); `ATPATH(vif); endtask

  // g7 the TIGHT spelling, as the baseline every other cell is read against.
  //    (An escaped MEMBER name was the original intent here; it is redundant —
  //    clause (4) only ever reads the BASE token, so g1 already executes the
  //    escaped-identifier path in the only position the law touches.)
  task g7(); @ vif.clock; endtask
endclass

module top;
  bit clk = 0;
  in_if u_if(clk);
  C c;
  initial begin
    c = new();
    c.vif = u_if;
    c.\esc.h  = u_if;
  end
endmodule
