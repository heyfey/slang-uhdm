// r10v183 arm F — the MUST-STAY faces: everything that must NOT move.
//   * the HOME package's own two listings (a resolved formal golden resolves
//     must STAY resolved);
//   * a MODULE that wildcard-imports the home and hoists nothing;
//   * a CLASS method in the home package, in-body and out-of-body;
//   * an INTERFACE-scope foreach;
//   * a package with NO import at all (the negative control lives in the
//     pass's own arm D; this one puts a no-import package beside a clone in
//     ONE file so the file is not trivially identical).
package st183_home;
  int home_arr[0:2];

  function automatic int h_fml(input int arg[0:2]);
    int acc = 0;
    foreach (arg[i]) acc += arg[i];
    return acc;
  endfunction

  function automatic int h_loc();
    int loc[0:2];
    int acc = 0;
    foreach (loc[i]) acc += loc[i];
    return acc;
  endfunction

  class st183_c;
    int prop[0:2];
    function int inbody();
      int acc = 0;
      foreach (prop[i]) acc += prop[i];
      return acc;
    endfunction
    extern function int outbody();
  endclass

  function int st183_c::outbody();
    int acc = 0;
    foreach (prop[i]) acc += prop[i];
    return acc;
  endfunction
endpackage

// a package with NO import of st183_home at all
package st183_alone;
  int alone_arr[0:2];
  function automatic int a_loc();
    int loc[0:2];
    int acc = 0;
    foreach (loc[i]) acc += loc[i];
    foreach (alone_arr[i]) acc += alone_arr[i];
    return acc;
  endfunction
endpackage

interface st183_if;
  int if_arr[0:2];
  function automatic int i_loc();
    int acc = 0;
    foreach (if_arr[i]) acc += if_arr[i];
    return acc;
  endfunction
endinterface

module st183_top;
  import st183_home::*;
  int marr[0:2];
  int r;
  function automatic int m_loc();
    int loc[0:2];
    int acc = 0;
    foreach (loc[i]) acc += loc[i];
    foreach (marr[i]) acc += marr[i];
    return acc;
  endfunction
  st183_if u_if();
  initial begin
    r = h_fml(marr) + h_loc() + m_loc() + st183_alone::a_loc();
  end
endmodule
