// vbuvm9 w4 — IMPORTED, RE-EXPORTED and cross-package typedefs.
package w4a;
  class ac; int a; endclass
  typedef struct { int a; } a1_s;   // wildcard-imported, oob nested local
  typedef struct { int a; } a2_s;   // explicit-imported, oob nested local
  typedef struct { int a; } a3_s;   // qualified-only, oob nested local
  typedef ac  a4_t;                 // class typedef, wildcard-imported
  typedef enum { AX, AY } a5_e;     // enum, wildcard-imported
  typedef struct { int a; } a6_s;   // used as oob FORMAL in the importer
  typedef struct { int a; } a7_s;   // used as oob RETURN in the importer
  class akc;
    typedef struct { int a; } ak_s; // CLASS-scope td in the exporting pkg
    extern function void f(int k);
  endclass
  function void akc::f(int k); if (k) begin ak_s v; v.a = 1; end endfunction
endpackage

package w4b;
  import w4a::*;                    // wildcard
  import w4a::a2_s;                 // explicit
  export w4a::*;                    // RE-EXPORT
  typedef struct { int a; } b1_s;
  class bk;
    extern function void f1(int k);
    extern function void f2(int k);
    extern function void f3(int k);
    extern function void f4(int k);
    extern function void f5(int k);
    extern function void f6(a6_s v);
    extern function a7_s f7();
    extern function void f8(int k);
  endclass
  function void bk::f1(int k); if (k) begin a1_s v; v.a = 1; end endfunction
  function void bk::f2(int k); if (k) begin a2_s v; v.a = 1; end endfunction
  function void bk::f3(int k); if (k) begin w4a::a3_s v; v.a = 1; end endfunction
  function void bk::f4(int k); if (k) begin a4_t v; v = null; end endfunction
  function void bk::f5(int k); if (k) begin a5_e v; v = AX; end endfunction
  function void bk::f6(a6_s v); endfunction
  function w4a::a7_s bk::f7(); a7_s r; r.a = 1; return r; endfunction
  function void bk::f8(int k); if (k) begin b1_s v; v.a = 1; end endfunction
endpackage

package w4c;
  import w4b::*;                    // reach a4a's names THROUGH the re-export
  class ck;
    extern function void f(int k);
    extern function void g(int k);
  endclass
  function void ck::f(int k); if (k) begin a1_s v; v.a = 1; end endfunction
  function void ck::g(int k); if (k) begin w4a::akc::ak_s v; v.a = 1; end endfunction
endpackage

module w4m;
  import w4b::*;
  initial begin end
endmodule
