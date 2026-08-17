// vbuvm9 w2 — CLASS-scope typedef, EVERY typespec kind, each referenced as a
// NESTED-BLOCK local of an OUT-OF-BODY method (the head's exact shape).
// The law removes the reference stamp on ClassOther and KEEPS it on ClassKeyTs.
package w2p;
  class oth; int a; endclass

  class kA; typedef logic [7:0] tA; extern function void f(int k); endclass
  function void kA::f(int k); if (k) begin tA v; v = 0; end endfunction

  class kB; typedef bit [3:0] tB; extern function void f(int k); endclass
  function void kB::f(int k); if (k) begin tB v; v = 0; end endfunction

  class kC; typedef int tC; extern function void f(int k); endclass
  function void kC::f(int k); if (k) begin tC v; v = 0; end endfunction

  class kD; typedef integer tD; extern function void f(int k); endclass
  function void kD::f(int k); if (k) begin tD v; v = 0; end endfunction

  class kE; typedef byte tE; extern function void f(int k); endclass
  function void kE::f(int k); if (k) begin tE v; v = 0; end endfunction

  class kF; typedef shortint tF; extern function void f(int k); endclass
  function void kF::f(int k); if (k) begin tF v; v = 0; end endfunction

  class kG; typedef longint tG; extern function void f(int k); endclass
  function void kG::f(int k); if (k) begin tG v; v = 0; end endfunction

  class kH; typedef enum { HX, HY } tH; extern function void f(int k); endclass
  function void kH::f(int k); if (k) begin tH v; v = HX; end endfunction

  class kI; typedef struct packed { int a; } tI; extern function void f(int k); endclass
  function void kI::f(int k); if (k) begin tI v; v.a = 0; end endfunction

  class kJ; typedef struct { int a; real b; } tJ; extern function void f(int k); endclass
  function void kJ::f(int k); if (k) begin tJ v; v.a = 0; end endfunction

  class kK; typedef union packed { int a; bit [31:0] b; } tK; extern function void f(int k); endclass
  function void kK::f(int k); if (k) begin tK v; v.a = 0; end endfunction

  class kL; typedef union { int a; real b; } tL; extern function void f(int k); endclass
  function void kL::f(int k); if (k) begin tL v; v.a = 0; end endfunction

  class kM; typedef string tM; extern function void f(int k); endclass
  function void kM::f(int k); if (k) begin tM v; v = "x"; end endfunction

  class kN; typedef real tN; extern function void f(int k); endclass
  function void kN::f(int k); if (k) begin tN v; v = 0.0; end endfunction

  class kO; typedef shortreal tO; extern function void f(int k); endclass
  function void kO::f(int k); if (k) begin tO v; v = 0.0; end endfunction

  class kP; typedef chandle tP; extern function void f(int k); endclass
  function void kP::f(int k); if (k) begin tP v; v = null; end endfunction

  class kQ; typedef event tQ; extern function void f(int k); endclass
  function void kQ::f(int k); if (k) begin tQ v; v = null; end endfunction

  class kR; typedef int tR [3]; extern function void f(int k); endclass
  function void kR::f(int k); if (k) begin tR v; v[0] = 0; end endfunction

  class kS; typedef logic [7:0][3:0] tS; extern function void f(int k); endclass
  function void kS::f(int k); if (k) begin tS v; v[0] = 0; end endfunction

  class kT; typedef int tT [$]; extern function void f(int k); endclass
  function void kT::f(int k); if (k) begin tT v; v.push_back(0); end endfunction

  class kU; typedef int tU []; extern function void f(int k); endclass
  function void kU::f(int k); if (k) begin tU v; v = new[2]; end endfunction

  class kV; typedef int tV [string]; extern function void f(int k); endclass
  function void kV::f(int k); if (k) begin tV v; v["a"] = 0; end endfunction

  // ClassKeyTs — the KEPT cell
  class kW; typedef oth tW; extern function void f(int k); endclass
  function void kW::f(int k); if (k) begin tW v; v = null; end endfunction

  // typedef OF a class-scope typedef
  class kX; typedef int tX0; typedef tX0 tX; extern function void f(int k); endclass
  function void kX::f(int k); if (k) begin tX v; v = 0; end endfunction

  // enum with an explicit base type
  class kY; typedef enum bit [1:0] { YA, YB } tY; extern function void f(int k); endclass
  function void kY::f(int k); if (k) begin tY v; v = YA; end endfunction

  // signed/unsigned keyword
  class kZ; typedef int unsigned tZ; extern function void f(int k); endclass
  function void kZ::f(int k); if (k) begin tZ v; v = 0; end endfunction
endpackage
