// r10v170 arm Q — THE TYPEDEF-SHAPE AXIS the implementer's arm E does not
// reach: a FORWARD typedef, a typedef declared INSIDE the exported subroutine
// (and inside a statement block), a THREE-LINK alias chain, an enum alias whose
// intermediate link is in a FOREIGN package, a NESTED class, and a local name
// that SHADOWS an imported one.  Every cell has a non-exported twin in the same
// file so a resolve/degrade PAIR lives in one compilation.
package ForeignQ3;
  typedef enum bit [1:0] { FQ_LO, FQ_HI } Hop_e;
  typedef Hop_e                            HopAlias_e;   // foreign alias link
  typedef enum bit [1:0] { SH0, SH1 }      Shadow_e;     // to be shadowed
endpackage

package Shapes3;
  import ForeignQ3::*;

  typedef enum Jump_e;                                   // FORWARD declaration
  typedef enum bit [1:0] { JMP_N, JMP_Y } Jump_e;        // ... completed here

  typedef enum bit [3:0] { L1, L2 } Link1_e;
  typedef Link1_e Link2_e;                               // 2-link chain
  typedef Link2_e Link3_e;                               // 3-link chain
  typedef ForeignQ3::Hop_e LocalOfForeign_e;             // alias of a FOREIGN enum
  typedef enum bit [1:0] { MY0, MY1 } Shadow_e;          // SHADOWS the import
  typedef struct packed { bit [1:0] p; bit [1:0] r; } Pair_s;
  typedef union  packed { bit [3:0] u; bit [3:0] v; } Sel_u;

  function void sink3(int q);
  endfunction

  export "DPI-C" function shaped3;
  function void shaped3(int v);
    sink3(int'(Jump_e'(v)));            // q01 forward-declared then completed
    sink3(int'(Link1_e'(v)));           // q02 direct enum typedef
    sink3(int'(Link2_e'(v)));           // q03 alias-of-enum-typedef
    sink3(int'(Link3_e'(v)));           // q04 alias-of-alias-of-enum-typedef
    sink3(int'(LocalOfForeign_e'(v)));  // q05 local alias of a FOREIGN enum
    sink3(int'(Shadow_e'(v)));          // q06 local name SHADOWING an import
    sink3(int'(Hop_e'(v)));             // q07 wildcard-imported, unshadowed
    sink3(int'(HopAlias_e'(v)));        // q08 wildcard-imported ALIAS
    sink3(int'(Pair_s'(v)));            // q09 own struct
    sink3(int'(Sel_u'(v)));             // q10 own union
    begin : blk3
      typedef enum bit [1:0] { IN0, IN1 } Inner_e;  // declared IN a block
      sink3(int'(Inner_e'(v)));         // q11 block-local typedef target
    end
  endfunction

  function void unshaped3(int v);       // the NON-exported twin, same cells
    sink3(int'(Jump_e'(v)));            // r01
    sink3(int'(Link1_e'(v)));           // r02
    sink3(int'(Link2_e'(v)));           // r03
    sink3(int'(Link3_e'(v)));           // r04
    sink3(int'(LocalOfForeign_e'(v)));  // r05
    sink3(int'(Shadow_e'(v)));          // r06
    sink3(int'(Hop_e'(v)));             // r07
    sink3(int'(HopAlias_e'(v)));        // r08
    sink3(int'(Pair_s'(v)));            // r09
    sink3(int'(Sel_u'(v)));             // r10
    begin : blk3b
      typedef enum bit [1:0] { IN2, IN3 } Inner_e;
      sink3(int'(Inner_e'(v)));         // r11
    end
  endfunction

  // NESTED classes inside the exported package — must never degrade.
  class Outer3;
    typedef enum bit [1:0] { O0, O1 } OuterK_e;
    int keep;
    class Inner3;
      int keep;
      function void mi(int v);
        keep = int'(Link1_e'(v));       // s01 nested class method, pkg enum
        keep = int'(Outer3::OuterK_e'(v)); // s02 nested class method, class enum
      endfunction
    endclass
    function void mo(int v);
      keep = int'(Link1_e'(v));         // s03 outer class method
    endfunction
  endclass
endpackage

module topQ170;
  initial Shapes3::unshaped3(2);
endmodule
