// r10uvm183 grid ARM E — THE WRITTEN-SPELLING AXIS inside a WILDCARD CLONE.
// Four spellings of the iterated reference already carry laws of their own —
// bare, `this.`-prefixed (§ classPropIterThisRefVar21, typespec-LESS),
// dotted (§ foreachHierPathAlwaysRes21, a hier_path) and `::`-scoped
// (§ foreachScopedArrayWrittenClassVar33, a class_var over a two-segment
// placeholder).  This arm puts every one of them inside a package a wildcard
// importer clones, so the PRECEDENCE between those laws and this pass's clone
// gate is measured rather than assumed.
package sp183;
  typedef enum bit [1:0] { ALFA0 = 0, BETA1 = 1 } tag_e;

  int shared_row[4];

  class Node183;
    int props[$];
    tag_e tags[];
    typedef Node183 this_kind;
    static int statics[3];

    function int bare_it();            // bare property name
      bare_it = 0;
      foreach (props[aa1]) bare_it++;
    endfunction

    function int this_it();            // explicit `this.`
      this_it = 0;
      foreach (this.props[bb2]) this_it++;
    endfunction

    function int scoped_it();          // `::`-scoped, written
      scoped_it = 0;
      foreach (Node183::statics[cc3]) scoped_it++;
    endfunction

    function int other_it(Node183 mate);   // dotted, through another handle
      other_it = 0;
      foreach (mate.props[dd4]) other_it++;
    endfunction

    extern function int outer_it();    // out-of-body definition
  endclass

  function int Node183::outer_it();    // hoisted body
    outer_it = 0;
    foreach (tags[ee5]) outer_it++;
  endfunction

  function automatic int free_pkgvar();
    free_pkgvar = 0;
    foreach (shared_row[ff6]) free_pkgvar += shared_row[ff6];
  endfunction
endpackage

package spwild183;
  import sp183::*;
  function automatic int drive();
    Node183 nd = new();
    return nd.bare_it() + nd.this_it() + nd.scoped_it() + nd.other_it(nd) +
           nd.outer_it() + free_pkgvar();
  endfunction
endpackage

module sp_top183;
  import spwild183::*;
  int got183;
  initial got183 = drive();
endmodule
