package quill182_home;
  function automatic int d1_fn();
    int sluice [$];
    int hob;
    hob = sluice.size;      // D_bare   -> ref_obj element
    hob = hob + sluice.size();  // D_parens -> method_func_call element
    return hob;
  endfunction
endpackage
package quill182_imp;
  import quill182_home::*;
  int quill182_anchor;
endpackage
module quill182_top;
  initial quill182_imp::quill182_anchor = 0;
endmodule
