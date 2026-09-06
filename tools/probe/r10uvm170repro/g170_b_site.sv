// r10uvm170 arm B — THE SITE AXIS: where a BARE same-package type name is
// written inside a DPI-exported package subroutine.  The law this pass
// installs owns the CAST TARGET only; every other site is a MEASURED residue
// and is here so the residue is a cell and not an opinion.
//
// NOTE ON THE RETURN/FORMAL CELLS: an enum is not a valid DPI return or
// argument type (slang rejects it, LRM 35.5.6), so those two sites are written
// with a same-package PACKED VECTOR alias `lb_t`, which is legal for DPI.
package pb170;
  typedef enum bit [1:0] { B0, B1 } eb_t;
  typedef struct packed { bit [3:0] b; } sb_t;
  typedef bit         lb_t;   // 1-bit: legal as a DPI RETURN type
  typedef bit   [7:0] vb_t;   // packed: legal as a DPI ARGUMENT type

  function void snk_b(int q);
  endfunction

  // ---- the EXPORTED subroutine: every site ------------------------------
  export "DPI-C" function fx_b;
  function lb_t fx_b(vb_t io_bare, int s);     // c01 return, c02 formal
    eb_t   loc_bare;                           // c03 subroutine local
    sb_t   loc_struct;                         // c04 subroutine local, struct
    begin
      eb_t blk_bare;                           // c05 statement-block local
      snk_b(0);
    end
    snk_b(int'(eb_t'(s)));                     // c06 cast target  <= THE LAW
    snk_b(int'(sb_t'(s)));                     // c07 cast target, struct
    fx_b = lb_t'(s);                           // c08 cast target on an assign
  endfunction

  export "DPI-C" task tx_b;
  task tx_b(vb_t io_bare, int s);              // c09 formal (task)
    eb_t loc_bare;                             // c10 task local
    snk_b(int'(eb_t'(s)));                     // c11 cast target (task)
  endtask

  // ---- the NON-exported twins -------------------------------------------
  function lb_t fy_b(vb_t io_bare, int s);     // d01 d02
    eb_t   loc_bare;                           // d03
    sb_t   loc_struct;                         // d04
    begin
      eb_t blk_bare;                           // d05
      snk_b(0);
    end
    snk_b(int'(eb_t'(s)));                     // d06
    snk_b(int'(sb_t'(s)));                     // d07
    fy_b = lb_t'(s);                           // d08
  endfunction

  task ty_b(vb_t io_bare, int s);              // d09
    eb_t loc_bare;                             // d10
    snk_b(int'(eb_t'(s)));                     // d11
  endtask

  // ---- a package VARIABLE and a class PROPERTY, outside any subroutine ---
  eb_t pkg_var;                                // e01 package variable
  class cb170;
    eb_t prop_bare;                            // e02 class property
    function void m(int s);
      snk_b(int'(eb_t'(s)));                   // e03 in-body class method cast
    endfunction
  endclass
endpackage

module top_b170;
  initial pb170::ty_b(8'h0, 1);
endmodule
