// r10buvm29 arm B — the CAST TARGET under a stream operand.
// Varies ONLY the target type written left of the `'`; the stream and the
// carrier are held at `{ << bit { __a } }` / assignment-Rhs.  uvm96's
// § castTargetKeywordTypespecKind96 says the target typespec KIND is a pure
// function of the WRITTEN KEYWORD -- this arm asserts that law still holds
// when the operand is a stream.
package b29;
  typedef enum { Z0, Z1 } e_bare;                       // base-less enum
  typedef enum bit [3:0] { W0, W1 } e_based;            // based enum
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s_pk;
  typedef logic [15:0] v_td;                            // typedef'd vector
  class C;
    e_bare  q1; e_based q2; s_pk q3; int q4; logic [7:0] q5; v_td q6;
    byte q7; shortint q8; longint q9; integer q10; bit q11; logic q12;
    function void f();
      bit __a[];
      q1  = e_bare'({ << bit { __a }});
      q2  = e_based'({ << bit { __a }});
      q3  = s_pk'({ << bit { __a }});
      q4  = int'({ << bit { __a }});
      // NO SIZE CAST CELL: slang REJECTS `N'({<<{x}})` outright --
      // "cannot change width or signedness of non-integral expression
      // (type is 'void')" -- for a fixed-size operand too.  That is why
      // Verilator/t_stream.v's five `4'({ << {4'b0001}})` sites are
      // SLANG_REJECT and out of scope, leaving uvm_pkg.sv:58249/:58284 as
      // the ONLY written-cast-over-a-stream cells in either corpus.
      q6  = v_td'({ << bit { __a }});
      q7  = byte'({ << bit { __a }});
      q8  = shortint'({ << bit { __a }});
      q9  = longint'({ << bit { __a }});
      q10 = integer'({ << bit { __a }});
      q11 = bit'({ << bit { __a }});
      q12 = logic'({ << bit { __a }});
      q5  = b29::v_td'({ << bit { __a }}); // a SCOPED typedef target
    endfunction
  endclass
endpackage
