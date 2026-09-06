// r10v181 arm B -- THE PREFIX / HIER_PATH axis, the surface the implementer's
// four arms never enter.
//
// Removing `if (!lm9.empty())` does not only open `bind9`'s CLIMB.  The whole
// deferred block in UhdmExporter.cpp is gated on
// `if (!pkgCloneBodyLocals9.empty())`, and inside it TWO other laws consult
// membership of the same map:
//
//   * `bind9` is also called on every `method_func_call`'s PREFIX;
//   * law pkgCloneMember10 refuses unless `pkgCloneBodyLocals9.count(tf10)` --
//     so a NON-BASE hier_path element in an EMPTYTF clone body could not
//     resolve against the preceding element's struct typespec before this
//     pass, and now can.
//
// This arm is those two laws, in an EMPTYTF body and in a HASLOCALS twin:
//   - a method call whose prefix is a BLOCK-LOCAL class handle   (climb)
//   - a method call whose prefix is a CLASS PROPERTY handle      (must stay bare)
//   - a method call whose prefix is a PACKAGE variable handle    (must stay bare)
//   - `this.method()`                                            (must stay bare)
//   - a hier_path on a BLOCK-LOCAL of a PACKAGE-scope struct type (member10)
//   - a hier_path on a BLOCK-LOCAL of a CLASS-scope struct type   (LAW-PCB: bare)
//   - a hier_path THREE elements deep, package-scope nested struct
//   - a hier_path whose base is the loop INDEX of an array OF STRUCTS
//   - a hier_path on a CLASS PROPERTY of struct type              (bare base)
//
// EMPTYTF here means literally no `Io_decls` and no `Variables` on the
// task_func: an implicit function-return name is not a `Variables()` entry, so
// every working value lives inside the `foreach`'s own `begin`.
package baldric_home;

  typedef struct packed { logic [3:0] cuisse; logic [3:0] greave; } sabaton_t;
  typedef struct packed { sabaton_t poleyn;  logic [3:0] tasset;  } gorget_t;

  sabaton_t baldric_pkgstruct;
  gorget_t  baldric_pkgnest;

  class vambrace_cls;
    int  vambrace_prop;
    function automatic int spaulder(input int couter);
      return couter + vambrace_prop;
    endfunction
  endclass

  vambrace_cls baldric_pkghandle;

  class rerebrace_cls;
    typedef struct packed { logic [3:0] besagew; logic [3:0] fauld; } cuirass_t;
    vambrace_cls rerebrace_prop;
    cuirass_t    rerebrace_clsstruct;
    sabaton_t    rerebrace_pkgtyped;
    int          rerebrace_arr [3];
    sabaton_t    rerebrace_structarr [3];

    extern function int gambeson181_empty();
    extern function int gambeson181_haslocal();
    extern function int vambrace181_dummy(input int couter);
  endclass

  function int rerebrace_cls::vambrace181_dummy(input int couter);
    return couter;
  endfunction

  // ---------- EMPTYTF: no formals, no function-scope Variables ----------
  function int rerebrace_cls::gambeson181_empty();
    foreach (rerebrace_arr[haubergeon]) begin
      vambrace_cls chausses;
      sabaton_t    plackart;
      cuirass_t    burgonet;
      int          gousset;
      gousset = 0;
      chausses = new();
      gousset = gousset + chausses.spaulder(haubergeon);       // block-local prefix
      gousset = gousset + rerebrace_prop.spaulder(haubergeon); // class property prefix
      gousset = gousset + baldric_pkghandle.spaulder(1);       // package var prefix
      gousset = gousset + this.vambrace181_dummy(haubergeon);  // this. prefix
      gousset = gousset + int'(plackart.cuisse);               // pkg-scope struct member
      gousset = gousset + int'(burgonet.besagew);              // CLASS-scope struct member
      gousset = gousset + int'(baldric_pkgnest.poleyn.greave); // 3-deep pkg nest
      gousset = gousset + int'(rerebrace_structarr[haubergeon].greave); // index base
      gousset = gousset + int'(rerebrace_pkgtyped.cuisse);     // property of struct type
      gambeson181_empty = gousset;
    end
  endfunction

  // ---------- HASLOCALS twin: identical body, one function-scope local ----
  function int rerebrace_cls::gambeson181_haslocal();
    int jupon;
    foreach (rerebrace_arr[haubergeon]) begin
      vambrace_cls chausses;
      sabaton_t    plackart;
      cuirass_t    burgonet;
      int          gousset;
      gousset = 0;
      chausses = new();
      gousset = gousset + chausses.spaulder(haubergeon);
      gousset = gousset + rerebrace_prop.spaulder(haubergeon);
      gousset = gousset + baldric_pkghandle.spaulder(1);
      gousset = gousset + this.vambrace181_dummy(haubergeon);
      gousset = gousset + int'(plackart.cuisse);
      gousset = gousset + int'(burgonet.besagew);
      gousset = gousset + int'(baldric_pkgnest.poleyn.greave);
      gousset = gousset + int'(rerebrace_structarr[haubergeon].greave);
      gousset = gousset + int'(rerebrace_pkgtyped.cuisse);
      jupon = gousset;
      gambeson181_haslocal = jupon;
    end
  endfunction

  // ---------- an EMPTYTF FREE function with the same prefixes -------------
  function automatic int corselet181_empty();
    foreach (baldric_pkgnest[surcoat]) begin
      vambrace_cls chausses;
      sabaton_t    plackart;
      chausses = new();
      corselet181_empty = chausses.spaulder(surcoat) +
                          int'(plackart.greave) +
                          int'(baldric_pkgnest.poleyn.cuisse) + surcoat;
    end
  endfunction

endpackage

package baldric_imp;
  import baldric_home::*;
  int baldric_anchor;
endpackage

module baldric_top;
  initial baldric_imp::baldric_anchor = 0;
endmodule
