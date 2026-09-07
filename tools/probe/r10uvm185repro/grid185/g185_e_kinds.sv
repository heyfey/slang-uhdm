// r10uvm185 grid arm E — EVERY VARIABLE CLASS the resolved arm can produce.
//
// When § classTdLocalVarKindFollowsCompileOrder10 answers `Resolved` for a
// prototype listing, `makeReturnVar` picks the class from the typespec exactly
// the way Surelog's `getSimpleVarFromTypespec` does.  The BuildUVMPkg head is
// the ENUM cell of this table; the rest are here so that "the enum case works"
// is not mistaken for "the law works", and so a wrong class in any other kind
// is a visible moved cell rather than an untested corner.
//
// The owner `ae185` sorts BEFORE `eu185`, so every cell below is on the
// RESOLVING side of the order term.  `ze185` repeats three of the kinds on the
// NON-resolving side as the paired negative control.
package pe185;

  // NO `chandle` CELL: a class-scoped `typedef chandle` SEGFAULTS the golden
  // Surelog outright (rc=139 on a five-line reduction), so the cell cannot be
  // scored on either side and is recorded rather than left as a silent gap.
  class ze185;
    typedef enum { EZ0, EZ1 } z_enum;
    typedef struct { int z; } z_rec;
    typedef int               z_int;
  endclass

  class ae185;
    typedef enum { EA0, EA1, EA2 } e_enum;
    typedef struct { int a; bit b; } e_rec;
    typedef struct packed { bit [3:0] a; bit [3:0] b; } e_prec;
    typedef union packed { bit [7:0] a; bit [7:0] b; } e_uni;
    typedef int          e_int;
    typedef byte         e_byte;
    typedef shortint     e_short;
    typedef longint      e_long;
    typedef integer      e_integer;
    typedef bit  [11:0]  e_bvec;
    typedef logic [5:0]  e_lvec;
    typedef real         e_real;
    typedef string       e_str;
    typedef ae185        e_cls;
    typedef shortreal    e_sreal;
    typedef time         e_time;
    typedef bit [3:0][7:0] e_parr;      // a PACKED 2-D array typedef
    typedef e_enum       e_alias;       // a NAMED base: the class's OWN typedef
    typedef ze185::z_enum e_xalias;     // a NAMED base in ANOTHER class
    typedef int          e_arr[4];
    typedef int          e_dyn[];
    typedef int          e_q[$];
    typedef int          e_assoc[string];
  endclass

  class eu185;
    extern function ae185::e_enum    k_enum();
    extern function ae185::e_rec     k_rec();
    extern function ae185::e_prec    k_prec();
    extern function ae185::e_uni     k_uni();
    extern function ae185::e_int     k_int();
    extern function ae185::e_byte    k_byte();
    extern function ae185::e_short   k_short();
    extern function ae185::e_long    k_long();
    extern function ae185::e_integer k_integer();
    extern function ae185::e_bvec    k_bvec();
    extern function ae185::e_lvec    k_lvec();
    extern function ae185::e_real    k_real();
    extern function ae185::e_str     k_str();
    extern function ae185::e_cls     k_cls();
    extern function ae185::e_sreal   k_sreal();
    extern function ae185::e_time    k_time();
    extern function ae185::e_parr    k_parr();
    extern function ae185::e_alias   k_alias();
    extern function ae185::e_xalias  k_xalias();
    extern function ae185::e_arr     k_arr();
    extern function ae185::e_dyn     k_dyn();
    extern function ae185::e_q       k_q();
    extern function ae185::e_assoc   k_assoc();
    // the paired NON-resolving control
    extern function ze185::z_enum    k_late_enum();
    extern function ze185::z_rec     k_late_rec();
    extern function ze185::z_int     k_late_int();
  endclass

  function ae185::e_enum    eu185::k_enum();    endfunction
  function ae185::e_rec     eu185::k_rec();     endfunction
  function ae185::e_prec    eu185::k_prec();    endfunction
  function ae185::e_uni     eu185::k_uni();     endfunction
  function ae185::e_int     eu185::k_int();     endfunction
  function ae185::e_byte    eu185::k_byte();    endfunction
  function ae185::e_short   eu185::k_short();   endfunction
  function ae185::e_long    eu185::k_long();    endfunction
  function ae185::e_integer eu185::k_integer(); endfunction
  function ae185::e_bvec    eu185::k_bvec();    endfunction
  function ae185::e_lvec    eu185::k_lvec();    endfunction
  function ae185::e_real    eu185::k_real();    endfunction
  function ae185::e_str     eu185::k_str();     endfunction
  function ae185::e_cls     eu185::k_cls();     endfunction
  function ae185::e_sreal   eu185::k_sreal();   endfunction
  function ae185::e_time    eu185::k_time();    endfunction
  function ae185::e_parr    eu185::k_parr();    endfunction
  function ae185::e_alias   eu185::k_alias();   endfunction
  function ae185::e_xalias  eu185::k_xalias();  endfunction
  function ae185::e_arr     eu185::k_arr();     endfunction
  function ae185::e_dyn     eu185::k_dyn();     endfunction
  function ae185::e_q       eu185::k_q();       endfunction
  function ae185::e_assoc   eu185::k_assoc();   endfunction
  function ze185::z_enum    eu185::k_late_enum(); endfunction
  function ze185::z_rec     eu185::k_late_rec();  endfunction
  function ze185::z_int     eu185::k_late_int();  endfunction

endpackage

module top185e;
  pe185::eu185 e;
  initial e = new();
endmodule
