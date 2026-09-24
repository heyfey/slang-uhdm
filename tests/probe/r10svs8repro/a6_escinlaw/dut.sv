// r10svs8 ARM a6 -- THE IN-LAW ESCAPED CONTROL.
//
// Arm a5 leaves ONE residual: for an ESCAPED receiver the spans of the
// method_func_call and of its prefix ref_obj run 5 columns short of golden's
// (names byte-EQUAL, only columns differ).  This arm decides WHOSE defect that
// is.  It writes the SAME escaped-receiver call on a plain CLASS handle --
// a shape that has taken the very same § covergroup-widened arm since long
// before this pass and is measurable on the CONTROL binary.
//
// H1  ESCAPED CLASS handle, dotted name:   \h.esc8 .touch();
// H2  ESCAPED CLASS handle, plain name:    \hesc8 .touch();
// H3  UNESCAPED control, same call:        h8.touch();
//
// If H1/H2 show the SAME column gap on the CONTROL binary, the gap belongs to
// the escaped-identifier SPAN law and this pass only made it VISIBLE for
// covergroups; if they are EQ, the gap is mine.
module a6;

  class tgt8;
    int u8;
    function void touch();
      u8 = 1;
    endfunction
  endclass

  class hold8;
    tgt8 \h.esc8 ;
    tgt8 \hesc8 ;
    tgt8 h8;

    task h1_8();
      \h.esc8 .touch();
    endtask

    task h2_8();
      \hesc8 .touch();
    endtask

    task h3_8();
      h8.touch();
    endtask
  endclass

endmodule
