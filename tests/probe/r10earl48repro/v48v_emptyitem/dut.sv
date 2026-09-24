// r10earl48 VERIFIER — the EMPTY-ITEM counterexample, ALONE, so the cmp head
// sits on it.  An else arm whose FIRST item is an empty item `;` and whose
// SECOND item is a named if-generate.  GOLDEN KEEPS THE LEVEL; the PRISTINE
// binary keeps it too (it agrees with golden); the PATCHED binary promotes.
module v48v_emptyitem ();
  wire a2;
  if (0) begin : x2_t
    wire t;
  end else begin : x2_e
    ;
    if (1) begin : x2_c
      wire c;
      assign c = 1'b0;
    end
  end
endmodule
