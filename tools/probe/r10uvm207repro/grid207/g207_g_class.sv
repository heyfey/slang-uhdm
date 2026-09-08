// r10uvm207 arm G — THE CLASS-PROPERTY QUESTION.  r10uvm205's R0 framed the
// next head as "a CLASS typespec between the reference and the subroutine".
// MEASURED, the corpus object is a struct_typespec — but the class shape is a
// real, separate question and this arm decides it against a real golden: a
// clone body local of CLASS type whose PROPERTY is a package scalar typedef.
// § `cloneBodyBareTdAlias180`'s class fence refuses it on purpose; this arm
// says whether golden bares it, so the fence is a MEASURED choice.
package p207a_g;
  typedef bit [63:0] bt207g;
  class C207g;
    bt207g g_prop207;
    function new(); g_prop207 = 0; endfunction
  endclass

  function automatic int fg207();
    C207g lg207;                          // a clone-reached CLASS-typed local
    lg207 = new();
    return int'(lg207.g_prop207);
  endfunction
endpackage

package p207b_g;
  import p207a_g::*;
  function automatic int gb207g();
    return fg207();
  endfunction
endpackage

module g207_g_class;
  import p207b_g::*;
  int r207g;
  initial r207g = gb207g();
endmodule
