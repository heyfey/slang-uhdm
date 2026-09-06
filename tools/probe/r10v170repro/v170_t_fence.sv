// r10v170 arm T — the two AWAY cells arm Q found, ISOLATED, each against a
// same-shape control in the SAME package so position cannot be the
// distinguisher:
//   * FORWARD-DECLARED typedef vs a plain one, in both orders;
//   * a bare name that is ALSO visible through a wildcard import, an EXPLICIT
//     import, and neither.
package DonorT2;
  typedef enum bit [1:0] { DT_0, DT_1 } Ghost_e;   // shadowed by a local later
  typedef enum bit [1:0] { DT_2, DT_3 } Solo_e;    // never shadowed
  typedef enum bit [1:0] { DT_4, DT_5 } Pick_e;    // explicitly imported
endpackage

package FenceT2;
  import DonorT2::*;
  import DonorT2::Pick_e;

  typedef enum Early_e;                            // FORWARD, first item
  typedef enum bit [1:0] { EA_0, EA_1 } Early_e;   // completion
  typedef enum bit [1:0] { PL_0, PL_1 } Plain_e;   // NO forward decl
  typedef enum bit [1:0] { LT_0, LT_1 } Late_e;    // completed after Tail_e's fwd
  typedef enum Tail_e;                             // FORWARD, after two plains
  typedef enum bit [1:0] { TA_0, TA_1 } Tail_e;    // completion
  typedef enum bit [1:0] { GH_0, GH_1 } Ghost_e;   // SHADOWS the wildcard import
  typedef struct packed { bit [2:0] s; } FwdS_s;   // plain struct control

  function void wellT2(int q);
  endfunction

  export "DPI-C" function coreT2;
  function void coreT2(int v);
    wellT2(int'(Early_e'(v)));   // t01 forward-declared, FIRST item
    wellT2(int'(Plain_e'(v)));   // t02 plain, no forward           -> DEGRADES
    wellT2(int'(Late_e'(v)));    // t03 plain, later position       -> DEGRADES
    wellT2(int'(Tail_e'(v)));    // t04 forward-declared, LATE
    wellT2(int'(FwdS_s'(v)));    // t05 plain struct                -> DEGRADES
    wellT2(int'(Ghost_e'(v)));   // t06 local name ALSO wildcard-imported
    wellT2(int'(Solo_e'(v)));    // t07 wildcard-imported only, no local
    wellT2(int'(Pick_e'(v)));    // t08 explicitly imported only, no local
  endfunction

  function void edgeT2(int v);   // the non-exported twin
    wellT2(int'(Early_e'(v)));   // w01
    wellT2(int'(Plain_e'(v)));   // w02
    wellT2(int'(Late_e'(v)));    // w03
    wellT2(int'(Tail_e'(v)));    // w04
    wellT2(int'(FwdS_s'(v)));    // w05
    wellT2(int'(Ghost_e'(v)));   // w06
    wellT2(int'(Solo_e'(v)));    // w07
    wellT2(int'(Pick_e'(v)));    // w08
  endfunction
endpackage

// A package with NO imports at all, same shapes — the import axis's control.
package CleanT2;
  typedef enum Fwd2_e;
  typedef enum bit [1:0] { F2_0, F2_1 } Fwd2_e;
  typedef enum bit [1:0] { P2_0, P2_1 } Pln2_e;
  function void wellC2(int q);
  endfunction
  export "DPI-C" function coreC2;
  function void coreC2(int v);
    wellC2(int'(Fwd2_e'(v)));    // t09 forward, no imports in package
    wellC2(int'(Pln2_e'(v)));    // t10 plain,   no imports in package
  endfunction
  function void edgeC2(int v);
    wellC2(int'(Fwd2_e'(v)));    // w09
    wellC2(int'(Pln2_e'(v)));    // w10
  endfunction
endpackage

module topT170;
  initial begin
    FenceT2::edgeT2(1);
    CleanT2::edgeC2(2);
  end
endmodule
