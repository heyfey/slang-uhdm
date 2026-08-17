// r10sd10 grid cell g8 — THE REFUTATION CELL: source order is IRRELEVANT.
// BOTH owner classes are written BEFORE both users, so a source-order rule
// ("the owner is declared first, therefore it is compiled first") predicts the
// SAME answer for both users.  Golden gives two DIFFERENT answers, and the only
// thing that separates them is the LEXICOGRAPHIC ORDER OF THE CLASS NAMES:
//     px::auser < px::zholder  -> the owner is compiled LATER -> class_var
//     px::ahold < px::zuser    -> the owner is compiled FIRST -> struct_var
package px;

  class zholder;                     // written FIRST, sorts LAST
    typedef struct { int a; } srec_t;
  endclass

  class ahold;                       // written SECOND, sorts FIRST
    typedef struct { int a; } trec_t;
  endclass

  class auser;                       // auser < zholder -> class_var
    function void f();
      zholder::srec_t v_early;
      v_early.a = 1;
    endfunction
  endclass

  class zuser;                       // ahold < zuser -> struct_var
    function void g();
      ahold::trec_t v_late;
      v_late.a = 1;
    endfunction
  endclass

endpackage

module top;
  px::auser a;
  px::zuser z;
  initial begin a = new(); z = new(); end
endmodule
