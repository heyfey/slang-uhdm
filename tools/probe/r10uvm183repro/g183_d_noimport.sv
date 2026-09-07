// r10uvm183 grid ARM D — THE NEGATIVE CONTROL.
// The same `foreach` bodies as arm A with NO package-to-package import
// anywhere: no wildcard importer, no explicit importer, so no clone is ever
// materialised and this law can never fire.  Every cell here must be
// BYTE-IDENTICAL under the two binaries in both views; a grid that reported
// zero over the arms the law DOES move could not see, so this arm is scored
// beside them, never instead of them.
package solo183;
  typedef enum bit [1:0] { ONE1 = 1, TWO2 = 2 } pick_e;

  string only_names[$];
  int    only_slots[5];

  function automatic int lone_fml(string wrds[$]);
    lone_fml = 0;
    foreach (wrds[n1]) lone_fml++;
  endfunction

  function automatic int lone_loc();
    int keep_bag[$];
    lone_loc = 0;
    keep_bag.push_back(17);
    foreach (keep_bag[o2]) lone_loc += keep_bag[o2];
  endfunction

  function automatic int lone_pkgvar();
    lone_pkgvar = 0;
    foreach (only_slots[u3]) lone_pkgvar += only_slots[u3];
  endfunction

  class Solo183;
    pick_e picks[];
    function int spin();
      spin = 0;
      foreach (picks[x4]) spin++;
    endfunction
  endclass
endpackage

module solo_top183;
  int lane183[3];
  int sum183;
  initial begin
    foreach (lane183[j5]) lane183[j5] = j5;
    sum183 = solo183::lone_loc();
  end
endmodule
