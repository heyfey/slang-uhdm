// r10v183 arm A — NAME-SHADOWING faces.  MEASUREMENT ONLY.
//
// Surelog's compileDatastructureTypespec consults `component->getDataType(
// typeName)` FIRST (CompileType.cpp:724) and the design's class definitions
// next (:727-745), BEFORE the param_assign scan the pass fenced on and BEFORE
// the unsupported_typespec tail.  So an iterated array whose NAME is also a
// TYPE name visible in the home package may RESOLVE in every listing, clone
// included — exactly the escape the parameter is.  This arm asks whether the
// law degrades such a cell.
package sh183_home;
  typedef int nm_arr[0:2];
  typedef int plain_t;
  class kls183;
    int q;
  endclass

  // (1) a variable of a typedef'd ARRAY type, named exactly like that type:
  //     golden's name-first lookup finds the typedef and its answer is the
  //     variable's OWN type.
  function automatic int f_selfname();
    nm_arr nm_arr;
    int acc = 0;
    foreach (nm_arr[i]) acc += nm_arr[i];
    return acc;
  endfunction

  // (2) a local array whose name is a SCALAR typedef name.
  function automatic int f_tdname();
    int plain_t[0:2];
    int acc = 0;
    foreach (plain_t[i]) acc += plain_t[i];
    return acc;
  endfunction

  // (3) a local array whose name is a CLASS name.
  function automatic int f_klsname();
    int kls183[0:2];
    int acc = 0;
    foreach (kls183[i]) acc += kls183[i];
    return acc;
  endfunction

  // (4) CONTROL — an ordinary local, nothing shadowed.
  function automatic int f_plain();
    int ctl_loc[0:2];
    int acc = 0;
    foreach (ctl_loc[i]) acc += ctl_loc[i];
    return acc;
  endfunction
endpackage

package sh183_clone;
  import sh183_home::*;
  export sh183_home::*;
  int use_sh;
  function automatic int kick_sh();
    return f_selfname() + f_tdname() + f_klsname() + f_plain();
  endfunction
endpackage

module sh183_top;
  import sh183_clone::*;
  int r;
  initial begin
    r = kick_sh();
  end
endmodule
