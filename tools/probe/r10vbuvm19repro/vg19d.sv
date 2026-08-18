// vbuvm19 adversarial grid D — the QUALIFIED-HEADER family (Surelog matches
// the late-binding name TEXTUALLY; our predicate matches the SYMBOL).
package vsrc19;
  int sv19[string];
  int sw19[string];
endpackage

package vuse19;
  import vsrc19::*;
  // 1 — header written PACKAGE-QUALIFIED, assignment written BARE
  function void xq19();
    foreach (vsrc19::sv19[i]) $display("xq", vsrc19::sv19[i]);
    sv19["a"] = 1;
  endfunction
  // 2 — header BARE, assignment BARE (positive control, imported var)
  function void xb19();
    foreach (sw19[i]) $display("xb", sw19[i]);
    sw19["b"] = 2;
  endfunction
endpackage

package vown19;
  int ov19[string];
  int ow19[string];
  // 3 — header qualified with its OWN package name, bare assignment
  function void oq19();
    foreach (vown19::ov19[i]) $display("oq", vown19::ov19[i]);
    ov19["c"] = 3;
  endfunction
  // 4 — header bare, assignment qualified with the own package name
  function void ob19();
    foreach (ow19[i]) $display("ob", ow19[i]);
    vown19::ow19["d"] = 4;
  endfunction
endpackage
