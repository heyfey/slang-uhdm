// r10v183 arm D — WHERE THE ITERATED OBJECT LIVES, inside one clone:
// formal / ref formal / subroutine local / STATIC subroutine local /
// statement-block local / package variable / the function's own RETURN
// VARIABLE.  The last one is a face the pass's arms do not carry: its name is
// the SUBROUTINE's name, which Surelog's name-first lookup sees as neither a
// type nor a parameter.
package hm183_home;
  typedef int quad_t[0:3];

  int pkg_slots[0:2];

  function automatic int f_fml(input int arg[0:2]);
    int acc = 0;
    foreach (arg[i]) acc += arg[i];
    return acc;
  endfunction

  task automatic t_ref(ref int r[0:2]);
    foreach (r[i]) r[i] = i;
  endtask

  function automatic int f_loc();
    int loc[0:2];
    int acc = 0;
    foreach (loc[i]) acc += loc[i];
    return acc;
  endfunction

  function automatic int f_static();
    static int sarr[0:2] = '{1, 2, 3};
    int acc = 0;
    foreach (sarr[i]) acc += sarr[i];
    return acc;
  endfunction

  function automatic int f_blk();
    int acc = 0;
    begin : inner
      int blkarr[0:2];
      foreach (blkarr[i]) acc += blkarr[i];
    end
    return acc;
  endfunction

  function automatic int f_pkgvar();
    int acc = 0;
    foreach (pkg_slots[i]) acc += pkg_slots[i];
    return acc;
  endfunction

  // the RETURN VARIABLE, iterated by its own (function) name
  function automatic quad_t f_retvar();
    foreach (f_retvar[i]) f_retvar[i] = i;
  endfunction
endpackage

package hm183_clone;
  import hm183_home::*;
  export hm183_home::*;
  int use_hm;
  function automatic int kick_hm();
    int a[0:2];
    quad_t q;
    q = f_retvar();
    return f_fml(a) + f_loc() + f_static() + f_blk() + f_pkgvar() + q[0];
  endfunction
  task automatic kick_hm_t();
    int a[0:2];
    t_ref(a);
  endtask
endpackage

module hm183_top;
  import hm183_clone::*;
  int r;
  initial begin
    r = kick_hm();
  end
endmodule
