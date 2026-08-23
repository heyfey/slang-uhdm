// r10uvm105 arm a2 — MEASUREMENT ONLY.  The HOMES the out-of-body body local
// can live in, and the INHERITED type-parameter spelling:
//   * a $unit (compilation-unit) class            -> what vpiInstance?
//   * a MODULE-nested class                       -> what vpiInstance?
//   * a class extending a PARAMETERISED BASE and writing the BASE's parameter
//     out-of-body                                 -> § baseClassTypeParamFormal
//                                                    Unsupported34's shape, one
//                                                    declaration kind wider
//   * a NON-parameterised class's out-of-body local (the negative control)
//   * a VALUE parameter used in an out-of-body local's RANGE (the control that
//     must resolve: a value parameter is not a type parameter)

// ---- $unit -----------------------------------------------------------------
class du105; int ux; endclass
class u105 #(type UT = du105);
  extern function void uf();
  function void uf_ib(); UT ib_u; endfunction
endclass
function void u105::uf();
  UT   uo_t;      // OUT-OF-BODY local, $unit home
  int  uo_i;      // control
endfunction

// ---- package: an INHERITED type parameter ----------------------------------
package q105;
  class bq105; int bx; endclass
  class base105 #(type BT = bq105);
    BT       b_prop;
    extern function void bmeth();
  endclass
  function void base105::bmeth();
    BT bo_t;                    // the class's OWN parameter, out-of-body
  endfunction

  class deri105 extends base105 #(bq105);
    extern function void dmeth();
    function void dmeth_ib(); BT di_t; endfunction   // INHERITED, IN-BODY
  endclass
  function void deri105::dmeth();
    BT do_t;                    // INHERITED parameter, OUT-OF-BODY
  endfunction

  // a NON-parameterised class: the negative control
  class plain105;
    extern function void pmeth();
  endclass
  function void plain105::pmeth();
    bq105 po_c;
    int   po_i;
  endfunction

  // a VALUE parameter, not a type parameter: must RESOLVE
  class vpar105 #(int WID = 8);
    extern function void vmeth();
  endclass
  function void vpar105::vmeth();
    logic [WID-1:0] vo_v;
  endfunction
endpackage

// ---- a MODULE-nested class -------------------------------------------------
module top105a;
  import q105::*;
  class dm105; int mx; endclass
  class m105 #(type MT = dm105);
    extern function void mf();
  endclass
  function void m105::mf();
    MT  mo_t;      // OUT-OF-BODY local, MODULE home
    int mo_i;
  endfunction

  u105    #(du105) hu;
  deri105          hd;
  plain105         hp;
  vpar105 #(4)     hv;
  m105             hm;
  initial begin
    hu = new(); hd = new(); hp = new(); hv = new(); hm = new();
  end
endmodule
