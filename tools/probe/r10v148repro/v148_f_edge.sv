// r10v148 arm F — THE EDGES: a for-loop iterator, a foreach loop variable, a
// TF-ITEM local whose INITIALISER reads another shadowed local, a package
// variable declared AFTER the subroutine that shadows it, an EXPLICIT-import
// shadow, output/inout/ref formals, unpacked-array / string / struct / const
// locals, a virtual method, a static package function, a default-argument
// expression, and a local whose name is the SUBROUTINE's own.
// MEASUREMENT ONLY.
package v6a_pkg;
  int imported_v6;
endpackage

package v6_pkg;
  import v6a_pkg::imported_v6;

  int    iter_v6;
  int    each_v6;
  int    seedv_v6;
  int    arr_v6 [4];
  string str_v6;
  int    cst_v6;
  int    dflt_v6;

  typedef struct packed { int a; } st_v6;
  st_v6 stv_v6;

  // a for-loop ITERATOR and a foreach LOOP VARIABLE that shadow package
  // variables, in a TF-ITEM body
  function void loops_tf_v6;
    int hold_v6;
    for (int iter_v6 = 0; iter_v6 < 2; iter_v6++) begin
      hold_v6 = iter_v6;
    end
    foreach (arr_v6[each_v6]) begin
      hold_v6 = each_v6;
    end
  endfunction

  // an INITIALISER that reads another shadowed TF-ITEM local
  function void init_tf_v6;
    int seedv_v6;
    int cst_v6 = 3;
    seedv_v6 = cst_v6;
  endfunction

  function void init_bk_v6();
    int seedv_v6;
    int cst_v6 = 3;
    seedv_v6 = cst_v6;
  endfunction

  // an EXPLICIT-import shadow: the local hides v6a_pkg::imported_v6
  function void imp_tf_v6;
    int imported_v6;
    imported_v6 = 1;
  endfunction

  // unpacked array / string / struct / const locals
  function void wide_tf_v6;
    int    arr_v6 [4];
    string str_v6;
    st_v6  stv_v6;
    arr_v6[0] = 1;
    str_v6    = "voussoir";
    stv_v6.a  = 2;
  endfunction

  function void wide_bk_v6();
    int    arr_v6 [4];
    string str_v6;
    st_v6  stv_v6;
    arr_v6[0] = 1;
    str_v6    = "voussoir";
    stv_v6.a  = 2;
  endfunction

  // output / inout / ref formals, and a body local beside them
  task io_tf_v6;
    output int seedv_v6;
    inout  int each_v6;
    int        iter_v6;
    iter_v6  = 1;
    seedv_v6 = iter_v6;
    each_v6  = iter_v6;
  endtask

  // a DEFAULT ARGUMENT expression that reads a shadowed name
  function void dflt_bk_v6(int q = dflt_v6);
    int dflt_v6;
    dflt_v6 = q;
  endfunction

  // a local whose name IS the function's own (the return-value arm)
  function int self_tf_v6;
    int seedv_v6;
    seedv_v6  = 1;
    self_tf_v6 = seedv_v6;
  endfunction

  class virt_v6;
    virtual function void vm_tf_v6;
      int seedv_v6;
      seedv_v6 = 1;
    endfunction
    extern virtual function void vo_tf_v6;
  endclass

  function void virt_v6::vo_tf_v6;
    int seedv_v6;
    seedv_v6 = 1;
  endfunction

  // A PACKAGE VARIABLE DECLARED *AFTER* THE SUBROUTINE THAT SHADOWS IT.
  function void late_tf_v6;
    int after_v6;
    after_v6 = 1;
  endfunction

  int after_v6;
endpackage

module v148_f_top;
  initial begin
    v6_pkg::loops_tf_v6();
    v6_pkg::init_tf_v6();
    v6_pkg::wide_tf_v6();
    v6_pkg::late_tf_v6();
  end
endmodule
