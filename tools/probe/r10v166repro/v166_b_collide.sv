// r10v166 ARM B — the COLLISION faces the brief names, as MUST-STAY controls.
// § blockLocalTdDeclIsRefVarUnsupported155 (uvm155) and § the statement-scope
// typedef LISTING law (uvm157) both live here; r10uvm166 must not touch one
// cell of either.  Every typedef name below is deliberately RE-USED across
// homes so that a name-keyed registration would race.
package cb166_pkg;

  class Elem166;
    int v;
  endclass

  typedef Elem166 shared166_t [$];             // PACKAGE registration of the name

  // (a) TWO METHODS OF ONE CLASS each declaring a statement-scope typedef of
  //     THE SAME NAME, with the SAME target.
  class TwoM166;
    function int m1_166();
      typedef Elem166 dup166_t [$];            // statement scope
      dup166_t d166;
      return d166.size();
    endfunction
    function int m2_166();
      typedef Elem166 dup166_t [$];            // same name, same target
      dup166_t d166;
      return d166.size();
    endfunction
    // (g) the SAME name with a DIFFERENT target, in a third method
    function int m3_166();
      typedef int dup166_t [$];                // same name, DIFFERENT target
      dup166_t d166;
      return d166.size();
    endfunction
  endclass

  // (b) TWO CLASSES each declaring the same typedef name at CLASS scope.
  class ClsA166;
    typedef Elem166 twin166_t [$];             // class home -> 166 FIRES
    function int a166();
      twin166_t t166;
      return t166.size();
    endfunction
  endclass
  class ClsB166;
    typedef Elem166 twin166_t [$];             // the OTHER class, same name
    function int b166();
      twin166_t t166;
      return t166.size();
    endfunction
  endclass

  // (c) A CLASS and a PACKAGE registering the same name.
  class ClsPkg166;
    typedef Elem166 shared166_t [$];           // shadows the package's
    function int c166();
      shared166_t s166;                        // resolves to the CLASS one
      return s166.size();
    endfunction
  endclass
  function automatic int pkgShared166();
    shared166_t s166;                          // resolves to the PACKAGE one
    return s166.size();
  endfunction

  // (e) A STATEMENT typedef colliding with a REAL typedef of the same name.
  typedef Elem166 real166_t [$];               // package-level REAL typedef
  class Shadow166;
    function int s166();
      typedef Elem166 real166_t [$];           // statement scope shadows it
      real166_t r166;
      return r166.size();
    endfunction
    function int t166();
      real166_t r166;                          // the PACKAGE one, unshadowed
      return r166.size();
    endfunction
  endclass

  // (j) A UNIQUE statement-scope typedef — uvm155's OWN law cell, must stay.
  class Uniq166;
    function int u166();
      typedef Elem166 onlyone166_t [$];
      onlyone166_t o166;
      return o166.size();
    endfunction
  endclass

  // (k) FORWARD typedefs, then the real ones.
  typedef class Fwd166;
  typedef Fwd166 fwdq166_t [$];
  class Fwd166;
    typedef Fwd166 selfq166_t [$];             // class home -> FIRES
    function int f166();
      selfq166_t sq166;
      fwdq166_t  fq166;                        // package home -> declines
      return sq166.size() + fq166.size();
    endfunction
  endclass

  // (l) The typedef NAME also naming a VARIABLE and a FUNCTION elsewhere.
  class NameClash166;
    typedef Elem166 nm166_t [$];
    int nm166_t_var;
    function int nm166_t_fn(); return 1; endfunction
    function int use166();
      nm166_t nm166;
      return nm166.size() + nm166_t_var + nm166_t_fn();
    endfunction
  endclass

endpackage

// (h) One side an IMPORTED class — uvm155's import fix must stay.
package cb166_imp;
  import cb166_pkg::*;
  class Imported166 extends Elem166;
    typedef Elem166 impq166_t [$];             // class home -> FIRES
    function int i166();
      impq166_t iq166;
      typedef Elem166 dup166_t [$];            // statement scope, name reused
      dup166_t d166;
      return iq166.size() + d166.size();
    endfunction
  endclass
  // a package FUNCTION naming an imported package's typedef
  function automatic int impFn166();
    cb166_pkg::real166_t r166;                 // SCOPED name -> declines
    return r166.size();
  endfunction
endpackage

// (d) A CLASS and a MODULE registering the same name; (f) THREE registrations
// in three homes.
module cb166_mod;
  import cb166_pkg::*;
  typedef Elem166 shared166_t [$];             // third registration of the name
  class InMod166;
    typedef Elem166 shared166_t [$];           // fourth, class-homed -> FIRES
    function int m166();
      shared166_t s166;
      return s166.size();
    endfunction
  endclass
  InMod166 im166;
  shared166_t modq166;                         // MODULE home -> declines
  int r166;
  initial begin
    typedef Elem166 initq166_t [$];            // statement scope in an initial
    initq166_t iq166;
    im166 = new();
    r166 = im166.m166() + modq166.size() + iq166.size();
  end
endmodule

// (i) A PROGRAM's initial — uvm155's carve-out must stay.
program cb166_prog;
  import cb166_pkg::*;
  typedef Elem166 shared166_t [$];             // program home -> declines
  class InProg166;
    typedef Elem166 shared166_t [$];           // class in a program -> FIRES
    function int p166();
      shared166_t s166;
      return s166.size();
    endfunction
  endclass
  InProg166 ip166;
  int r166;
  initial begin
    typedef Elem166 progq166_t [$];            // statement scope in a program
    progq166_t pq166;
    shared166_t sq166;                         // program home -> declines
    ip166 = new();
    r166 = ip166.p166() + pq166.size() + sq166.size();
  end
endprogram

module cb166_top;
  import cb166_pkg::*;
  cb166_mod  u_mod166 ();
  cb166_prog u_prog166 ();
  TwoM166 t166; ClsA166 a166; ClsB166 b166; ClsPkg166 c166;
  Shadow166 s166; Uniq166 q166; Fwd166 f166; NameClash166 n166;
  cb166_imp::Imported166 i166;
  int r166;
  initial begin
    t166 = new(); a166 = new(); b166 = new(); c166 = new();
    s166 = new(); q166 = new(); f166 = new(); n166 = new(); i166 = new();
    r166 = t166.m1_166() + t166.m2_166() + t166.m3_166()
         + a166.a166() + b166.b166() + c166.c166() + pkgShared166()
         + s166.s166() + s166.t166() + q166.u166() + f166.f166()
         + n166.use166() + i166.i166() + cb166_imp::impFn166();
  end
endmodule
