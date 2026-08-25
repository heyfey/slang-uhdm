// r10v148 arm D — KINDS AND LIFETIMES: static vs automatic local, an
// INITIALISED TF-ITEM local (uvm145's hoist), a nested-`begin` local, one name
// in two methods, a nested class, and a local shadowing a package variable
// referenced from inside a nested block.  MEASUREMENT ONLY.
package v4_pkg;
  int wid_v4;
  int nar_v4;

  // static-lifetime locals under both productions
  function void st_tf_v4;
    static int wid_v4;
    static int nar_v4;
    wid_v4 = 1;
    nar_v4 = wid_v4;
  endfunction

  function void st_bk_v4();
    static int wid_v4;
    static int nar_v4;
    wid_v4 = 1;
    nar_v4 = wid_v4;
  endfunction

  // automatic-lifetime locals under both productions
  function automatic void au_tf_v4;
    int wid_v4;
    int nar_v4;
    wid_v4 = 1;
    nar_v4 = wid_v4;
  endfunction

  function automatic void au_bk_v4();
    int wid_v4;
    int nar_v4;
    wid_v4 = 1;
    nar_v4 = wid_v4;
  endfunction

  // an INITIALISED TF-ITEM local (uvm145's no-statement hoist)
  function void in_tf_v4;
    static int wid_v4 = 4;
    int nar_v4;
    nar_v4 = wid_v4;
  endfunction

  function void in_bk_v4();
    static int wid_v4 = 4;
    int nar_v4;
    nar_v4 = wid_v4;
  endfunction

  // a NESTED `begin`'s own local, under the TF-ITEM production: uvm145's
  // inner-block fence — it must KEEP its binding under both productions.
  function void ne_tf_v4;
    int nar_v4;
    nar_v4 = 0;
    begin : inner
      int wid_v4;
      wid_v4 = 1;
      nar_v4 = wid_v4;
    end
  endfunction

  function void ne_bk_v4();
    int nar_v4;
    nar_v4 = 0;
    begin : inner
      int wid_v4;
      wid_v4 = 1;
      nar_v4 = wid_v4;
    end
  endfunction

  // a TF-ITEM body local referenced from INSIDE a nested `begin`
  function void bd_tf_v4;
    int wid_v4;
    begin : deeper
      wid_v4 = 2;
    end
  endfunction

  // THE SAME NAME in two methods, opposite productions
  function void tw_a_v4;
    int wid_v4;
    wid_v4 = 1;
  endfunction

  function void tw_b_v4();
    int wid_v4;
    wid_v4 = 1;
  endfunction

  class outer_v4;
    int wid_v4;
    class inner_v4;
      int wid_v4;
      function void icfn_tf_v4;
        int wid_v4;
        wid_v4 = 1;
      endfunction
    endclass
    extern function void ocfn_tf_v4;
  endclass

  function void outer_v4::ocfn_tf_v4;
    int wid_v4;
    wid_v4 = 1;
    nar_v4 = wid_v4;
  endfunction
endpackage

