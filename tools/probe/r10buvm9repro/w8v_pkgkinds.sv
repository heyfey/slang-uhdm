// vbuvm9 w8 — PACKAGE-scope typedef, EVERY typespec kind, each referenced as a
// NESTED-BLOCK local of an OUT-OF-BODY class method: the DEF and ELAB listing
// entries of the (PkgOther | PkgClassTs) split, kind by kind.
package w8p;
  class oth; int a; endclass
  typedef logic [7:0]                   pA;
  typedef bit [3:0]                     pB;
  typedef int                           pC;
  typedef integer                       pD;
  typedef byte                          pE;
  typedef shortint                      pF;
  typedef longint                       pG;
  typedef enum { HX, HY }               pH;
  typedef struct packed { int a; }      pI;
  typedef struct { int a; real b; }     pJ;
  typedef union packed { int a; bit [31:0] b; } pK;
  typedef union { int a; real b; }      pL;
  typedef string                        pM;
  typedef real                          pN;
  typedef shortreal                     pO;
  typedef chandle                       pP;
  typedef event                         pQ;
  typedef int                           pR [3];
  typedef logic [7:0][3:0]              pS;
  typedef int                           pT [$];
  typedef int                           pU [];
  typedef int                           pV [string];
  typedef oth                           pW;   // PkgClassTs
  typedef pC                            pX;   // typedef OF a typedef
  typedef enum bit [1:0] { YA, YB }     pY;
  typedef int unsigned                  pZ;

  class w8k;
    extern function void fA(int k); extern function void fB(int k);
    extern function void fC(int k); extern function void fD(int k);
    extern function void fE(int k); extern function void fF(int k);
    extern function void fG(int k); extern function void fH(int k);
    extern function void fI(int k); extern function void fJ(int k);
    extern function void fK(int k); extern function void fL(int k);
    extern function void fM(int k); extern function void fN(int k);
    extern function void fO(int k); extern function void fP(int k);
    extern function void fQ(int k); extern function void fR(int k);
    extern function void fS(int k); extern function void fT(int k);
    extern function void fU(int k); extern function void fV(int k);
    extern function void fW(int k); extern function void fX(int k);
    extern function void fY(int k); extern function void fZ(int k);
  endclass
  function void w8k::fA(int k); if (k) begin pA v; v=0; end endfunction
  function void w8k::fB(int k); if (k) begin pB v; v=0; end endfunction
  function void w8k::fC(int k); if (k) begin pC v; v=0; end endfunction
  function void w8k::fD(int k); if (k) begin pD v; v=0; end endfunction
  function void w8k::fE(int k); if (k) begin pE v; v=0; end endfunction
  function void w8k::fF(int k); if (k) begin pF v; v=0; end endfunction
  function void w8k::fG(int k); if (k) begin pG v; v=0; end endfunction
  function void w8k::fH(int k); if (k) begin pH v; v=HX; end endfunction
  function void w8k::fI(int k); if (k) begin pI v; v.a=0; end endfunction
  function void w8k::fJ(int k); if (k) begin pJ v; v.a=0; end endfunction
  function void w8k::fK(int k); if (k) begin pK v; v.a=0; end endfunction
  function void w8k::fL(int k); if (k) begin pL v; v.a=0; end endfunction
  function void w8k::fM(int k); if (k) begin pM v; v="x"; end endfunction
  function void w8k::fN(int k); if (k) begin pN v; v=0.0; end endfunction
  function void w8k::fO(int k); if (k) begin pO v; v=0.0; end endfunction
  function void w8k::fP(int k); if (k) begin pP v; v=null; end endfunction
  function void w8k::fQ(int k); if (k) begin pQ v; v=null; end endfunction
  function void w8k::fR(int k); if (k) begin pR v; v[0]=0; end endfunction
  function void w8k::fS(int k); if (k) begin pS v; v[0]=0; end endfunction
  function void w8k::fT(int k); if (k) begin pT v; v.push_back(0); end endfunction
  function void w8k::fU(int k); if (k) begin pU v; v=new[2]; end endfunction
  function void w8k::fV(int k); if (k) begin pV v; v["a"]=0; end endfunction
  function void w8k::fW(int k); if (k) begin pW v; v=null; end endfunction
  function void w8k::fX(int k); if (k) begin pX v; v=0; end endfunction
  function void w8k::fY(int k); if (k) begin pY v; v=YA; end endfunction
  function void w8k::fZ(int k); if (k) begin pZ v; v=0; end endfunction
endpackage
