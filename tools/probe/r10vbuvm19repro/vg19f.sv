// vbuvm19 adversarial grid F — the Variables()-before-Stmts() boundary:
// declaration FORMS that may not reach our VariableDeclStatement test.
package vfp19;
  function void statloc19();
    begin
      static int sa19[string];              // STATIC block-local
      foreach (sa19[i]) $display("st", sa19[i]);
      sa19["a"] = 1;
    end
  endfunction

  function automatic void autoloc19();
    begin
      automatic int aa19[string];           // AUTOMATIC block-local
      foreach (aa19[i]) $display("au", aa19[i]);
      aa19["b"] = 2;
    end
  endfunction

  function void namedloc19();
    begin : nb19
      int na19[string];                     // named-block local
      foreach (na19[i]) $display("nl", na19[i]);
      na19["c"] = 3;
    end
  endfunction

  function void initloc19();
    int ia19[string] = '{"x":1};            // local WITH an initializer
    foreach (ia19[i]) $display("il", ia19[i]);
    ia19["d"] = 4;
  endfunction

  typedef int vt19[string];
  function void tdloc19();
    vt19 ta19;                              // typedef'd local
    foreach (ta19[i]) $display("tl", ta19[i]);
    ta19["e"] = 5;
  endfunction

  function void constloc19();
    const int ca19[4] = '{0,1,2,3};         // const local (no assignment)
    foreach (ca19[i]) $display("cl", ca19[i]);
  endfunction

  int gv19[string];
  function void gctrl19();                  // positive control
    foreach (gv19[i]) $display("gc", gv19[i]);
    gv19["f"] = 6;
  endfunction
endpackage
