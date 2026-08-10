// t43a — THE DPI-IMPORT FORMAL TYPESPEC 2x2 (pass 33).
//
// Pass 32 decoded WHAT golden does (a DPI import's formal binds the shared
// package-typedef LISTING object, qualified, where a plain function's formal
// takes a per-declaration bare CLONE) and proved the fix cannot live in LAW S.
// This arm pins the cells the SITE needs before any code is written:
//
//   (a) does the law need an IMPORTER at all?  p43n has a DPI import and a
//       vector typedef and NOBODY imports it, so there is no second-generation
//       listing object for the formal to bind — if golden still binds a
//       listing object it must be the package's own.
//   (b) WHICH generation when there ARE importers — p43v, imported by p43a and
//       p43b (t41b already says the LAST importer owns it; repeated here so
//       one census answers both).
//   (c) `context` vs plain DPI, and a TASK import (`import "DPI-C" task`) —
//       UVM's counter-example `uvm_hdl_force_time` is a plain SV task, so the
//       predicate must not be "task".
//   (d) the AGGREGATE formals: enum and struct typedefs (t41b says a DPI enum
//       formal degrades to `unsupported_typespec` in its own package).
//   (e) a CROSS-PACKAGE typedef formal (a DPI import in p43x typed by p43v's
//       typedef), and an ALIAS-OF-ALIAS one (LAW S's own exception).
//   (f) DPI imports OUTSIDE a package: at $unit scope and inside a MODULE.
//   (g) the RETURN type of a DPI import written as a vector typedef.
//   (h) the CONTROL in every home: a plain function with the identical formal.

package p43n;                       // (a) NOBODY imports this package
  typedef logic [7:0] n_t;
  typedef enum int { N0, N1 } nen_t;
  import "DPI-C" context function int dn_lit(string path, n_t value);
  function int pn_lit(input string path, input n_t value); return 0;
  endfunction
endpackage

package p43v;
  typedef logic [7:0]          v_t;
  typedef bit   [3:0]          vb_t;
  typedef int                  vi_t;      // UNRANGED scalar typedef
  typedef v_t                  vaa_t;     // ALIAS OF ALIAS (LAW S exception)
  typedef enum int { E0, E1 }  ven_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } vst_t;

  // (b)/(c)/(d)/(g) every DPI shape over those typedefs
  import "DPI-C" context function int  dv_lit (string path, v_t   value);
  import "DPI-C"         function int  dv_np  (string path, v_t   value);
  import "DPI-C" context task          dv_task(string path, v_t   value);
  import "DPI-C" context function int  dv_out (string path, output v_t value);
  import "DPI-C" context function int  dv_bit (string path, vb_t  value);
  import "DPI-C" context function int  dv_int (string path, vi_t  value);
  import "DPI-C" context function int  dv_aa  (string path, vaa_t value);
  import "DPI-C" context function int  dv_en  (string path, ven_t value);
  import "DPI-C" context function int  dv_st  (string path, vst_t value);
  // (g) a DPI return type must be a scalar — slang rejects a vector typedef
  // return outright, so the RETURN cell is the UNRANGED scalar typedef.
  import "DPI-C" context function vi_t dv_ret (string path);

  // (h) the CONTROLS: plain SV subroutines with the identical formals
  function int pv_lit(input string path, input v_t value); return 0;
  endfunction
  task pv_task(input string path, input v_t value); endtask
  function int pv_en(input string path, input ven_t value); return 0;
  endfunction
  function int pv_st(input string path, input vst_t value); return 0;
  endfunction
  function v_t pv_ret(input string path); return 0; endfunction
endpackage

// (e) a DPI import in ANOTHER package typed by p43v's typedef
package p43x;
  import p43v::*;
  import "DPI-C" context function int dx_lit(string path, v_t value);
  function int px_lit(input string path, input v_t value); return 0;
  endfunction
endpackage

// (b) TWO importers of p43v, so "last importer wins" has something to win
package p43a;
  import p43v::*;
  function void a_use(input v_t a); endfunction
endpackage

package p43b;
  import p43v::*;
  function void b_use(input v_t a); endfunction
endpackage

// (f) $unit-scope DPI import over a package-qualified typedef
import "DPI-C" context function int du_lit(string path, p43v::v_t value);
function int pu_lit(input string path, input p43v::v_t value); return 0;
endfunction

module top43a;
  import p43v::*;
  import p43n::*;
  import p43x::*;
  import p43a::*;
  import p43b::*;

  // (f) a DPI import declared INSIDE a module
  import "DPI-C" context function int dm_lit(string path, v_t value);
  function int pm_lit(input string path, input v_t value); return 0;
  endfunction

  v_t   w;
  ven_t e;
  initial begin
    void'(dv_lit("p", w));
    void'(pv_lit("p", w));
    void'(dn_lit("p", 8'h1));
    void'(dx_lit("p", w));
    void'(du_lit("p", w));
    void'(dm_lit("p", w));
    a_use(w); b_use(w);
  end
endmodule
