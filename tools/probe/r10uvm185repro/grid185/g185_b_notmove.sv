// r10uvm185 grid arm B — WHAT THIS LAW MUST NOT TOUCH.
//
// § classTdLocalVarKindFollowsCompileOrder10 answers `Resolved` and returns
// early for every return type that is NOT a typedef owned by a class, so
// § externProtoRetVarKindIsPrototypeCompile185 — which only changes WHICH
// SYMBOL that predicate is asked about — must change nothing here.  Every cell
// below is an `extern` method (so the new gate DOES run) whose return type is
// one of the shapes the predicate leaves alone.
//
// It also carries the neighbouring return-var laws that share the emission
// site, so a regression in any of them shows up as a moved cell rather than as
// a silent difference: § implicitRetSigningIsIntVar70 (`b_implicit`,
// `b_signed`), § namedBaseUnpackedTdRetVar22 (`b_unp_td`), and
// § ownNamedAliasRetIsRefVar177 (`b_pkgalias`, whose base is a NAMED type
// declared in this very package).
package pb185;

  typedef enum { PB0, PB1 }   pkg_enum;
  typedef struct { int p; }   pkg_rec;
  typedef pkg_enum            pkg_alias;      // NAMED base — law 177's shape
  typedef int                 pkg_arr_t[3];   // law 22's shape
  typedef bit [15:0]          pkg_vec;

  class kb185;
    int q;
  endclass

  class notmove185;
    // builtin / keyword return types
    extern function int          b_int();
    extern function bit [3:0]    b_vec();
    extern function string       b_str();
    extern function real         b_real();
    extern function              b_implicit();
    extern function signed [7:0] b_signed();
    // an INLINE enum written at the return-type token.  (An inline packed
    // STRUCT is not a cell: slang refuses the shape outright — "return type
    // 'struct packed{…}' of method does not match 'struct packed{…}' declared
    // in its prototype", the two anonymous types being distinct — so our
    // emitter can never be asked the question.)
    extern function enum { BE0, BE1 } b_inline_enum();
    // PACKAGE-level typedefs (not owned by a class)
    extern function pkg_enum     b_pkg_enum();
    extern function pkg_rec      b_pkg_rec();
    extern function pkg_vec      b_pkg_vec();
    extern function pkg_alias    b_pkgalias();
    extern function pkg_arr_t    b_unp_td();
    // a CLASS HANDLE to a top-level class (not a class-owned typedef)
    extern function kb185        b_handle();
    // a TASK prototype has no return variable at all
    extern task                  b_task(input int a);
    // and an `extern` CONSTRUCTOR prototype, whose return var is synthesized
    // by a different site entirely
    extern function new(int a);
  endclass

  function int          notmove185::b_int();        return 0;    endfunction
  function bit [3:0]    notmove185::b_vec();        return 4'd0; endfunction
  function string       notmove185::b_str();        return "";   endfunction
  function real         notmove185::b_real();       return 0.0;  endfunction
  function              notmove185::b_implicit();   return 0;    endfunction
  function signed [7:0] notmove185::b_signed();     return 0;    endfunction
  function enum { BE0, BE1 } notmove185::b_inline_enum(); return BE0; endfunction
  function pb185::pkg_enum  notmove185::b_pkg_enum();  return PB0; endfunction
  function pb185::pkg_rec   notmove185::b_pkg_rec();   b_pkg_rec = '{p:0}; endfunction
  function pb185::pkg_vec   notmove185::b_pkg_vec();   return '0;  endfunction
  function pb185::pkg_alias notmove185::b_pkgalias();  return PB1; endfunction
  function pb185::pkg_arr_t notmove185::b_unp_td();    b_unp_td = '{0,0,0}; endfunction
  function pb185::kb185     notmove185::b_handle();    return null; endfunction
  task                      notmove185::b_task(input int a); endtask
  function                  notmove185::new(int a);    endfunction

  // A `parameter type` RETURN.  slang models a class TYPE PARAMETER as a
  // `TypeAliasType` owned by the class, so it walks into this law's population
  // gate, but it is not a typedef: Surelog resolves it through the
  // specialization and golden's prototype listing is a `class_var`.  The law
  // DECLINES it, exactly as § ownNamedAliasRetIsRefVar177 does.  The WIDE
  // boundary caught this on three committed arms before the cell existed here
  // (`r10uvm105repro/g105_a1.sv` `oob_ret`, `r10v105repro/v105_b4.sv` `retm`,
  // `r10v107repro/v107_b6.sv` `ret_bare`).
  class parmb185 #(type T = kb185);
    extern function T    b_typeparam();
    extern function void b_typeparam_arg(input T a);
  endclass
  function parmb185::T parmb185::b_typeparam();       return null; endfunction
  function void parmb185::b_typeparam_arg(input T a); endfunction

endpackage

module top185b;
  pb185::notmove185 n;
  pb185::parmb185#(pb185::kb185) pm;
  initial begin
    n = new(1);
    pm = new();
  end
endmodule
