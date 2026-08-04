// t26 — the typedef NAMING half, BOTH directions, on the UVM shape.
//
// UVM: `uvm_pkg` declares the scalar typedefs and the classes; `adpcm_pkg`
// imports `uvm_pkg::*` and both packages' Task_funcs / Class_defns lists get
// walked.  The pass-15 residue says golden names the SAME typedef's typespec
// QUALIFIED at some sites and BARE at others; the question this pins is WHICH
// SITE, not which typedef.
//
// Sites covered for one ranged bit typedef, one ranged logic typedef and one
// unranged int typedef:
//   - free package function FORMAL          (uvm_hdl_deposit's shape)
//   - free package function LOCAL
//   - free package function RETURN
//   - class method FORMAL / LOCAL           (uvm_reg::get_address's shape)
//   - class PROPERTY
//   - package-scope VARIABLE
//   - module VARIABLE / module net
// each visible from the DECLARING package and from the IMPORTING package.

package p_decl;

  typedef bit unsigned [7:0] bt;      // uvm_reg_addr_t's shape
  typedef logic [7:0]        lt;      // uvm_hdl_data_t's shape
  typedef int                it;       // UVM_FILE's shape

  bt pkgvar_b;
  lt pkgvar_l;
  it pkgvar_i;

  // free package function: formal + local + return
  function bt free_fn(bt fa, lt fb, it fc);
    bt loc_b;
    lt loc_l;
    it loc_i;
    loc_b = fa;
    loc_l = fb;
    loc_i = fc;
    return loc_b;
  endfunction

  task free_tk(lt ta);
    lt loc_l;
    loc_l = ta;
  endtask

  class C;
    bt prop_b;
    lt prop_l;
    it prop_i;
    function bt m_fn(bt ma, lt mb, it mc);
      bt mloc_b;
      lt mloc_l;
      it mloc_i;
      mloc_b = ma;
      mloc_l = mb;
      mloc_i = mc;
      return mloc_b;
    endfunction
  endclass

endpackage : p_decl

package p_imp;
  import p_decl::*;

  // a class of the IMPORTING package whose members use the imported typedefs
  class D;
    bt dprop_b;
    lt dprop_l;
    function bt d_fn(bt da, lt db);
      bt dloc_b;
      dloc_b = da;
      return dloc_b;
    endfunction
  endclass

  function bt imp_fn(bt ia, lt ib);
    bt iloc_b;
    iloc_b = ia;
    return iloc_b;
  endfunction

endpackage : p_imp

module top;
  import p_decl::*;
  import p_imp::*;

  bt modvar_b;
  lt modvar_l;
  it modvar_i;
  wire lt modnet_l;

  function bt mod_fn(bt xa, lt xb);
    bt xloc_b;
    xloc_b = xa;
    return xloc_b;
  endfunction

  initial begin
    modvar_b = mod_fn(8'h1, 8'h2);
  end
endmodule
