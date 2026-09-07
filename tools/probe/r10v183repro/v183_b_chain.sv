// r10v183 arm B — 1..3 INSTANCES of the clone: one home, TWO independent
// wildcard importers, and a clone OF A CLONE (transitive re-export).  The
// pass's own arms carry a single importer; this asks whether the INSTANCE
// half stamps the ORIGINAL home on every copy at every depth.
package ch183_home;
  typedef int quad_t[0:3];

  function automatic int leaf_fml(input int arg[0:2]);
    int acc = 0;
    foreach (arg[i]) acc += arg[i];
    return acc;
  endfunction

  function automatic int leaf_loc();
    string words[$];
    int acc = 0;
    words.push_back("x");
    foreach (words[i]) acc++;
    return acc;
  endfunction

  int home_pkgarr[0:2];
  function automatic int leaf_pkgvar();
    int acc = 0;
    foreach (home_pkgarr[i]) acc += home_pkgarr[i];
    return acc;
  endfunction
endpackage

// clone instance #1
package ch183_c1;
  import ch183_home::*;
  export ch183_home::*;
  int u1;
  function automatic int k1();
    int a[0:2];
    return leaf_fml(a) + leaf_loc() + leaf_pkgvar();
  endfunction
endpackage

// clone instance #2 — a SECOND, independent importer of the same home
package ch183_c2;
  import ch183_home::*;
  export ch183_home::*;
  int u2;
  function automatic int k2();
    int b[0:2];
    return leaf_fml(b) + leaf_loc();
  endfunction
endpackage

// clone instance #3 — a clone OF A CLONE (transitive)
package ch183_c3;
  import ch183_c1::*;
  export ch183_c1::*;
  int u3;
  function automatic int k3();
    int c[0:2];
    return leaf_fml(c) + k1();
  endfunction
endpackage

module ch183_top;
  import ch183_c3::*;
  import ch183_c2::*;
  int r;
  initial begin
    r = k3() + k2();
  end
endmodule
