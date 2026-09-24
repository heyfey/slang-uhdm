// r10uvm134 grid A — ARRAY KINDS x KEY TYPES for the § 134 loop list.
// Names deliberately UNALIKE (no a_t/b_t/c_t self-confirming grid).
package qa134;

  typedef enum { EK_ZERO, EK_ONE, EK_TWO } ekey134_t;

  class Grain;
    int          gi[];
    string       gs[$];
    bit [7:0]    gb[4];
    Grain        gr[];
    int          byStr[string];
    int          byInt[int];
    int          byEnum[ekey134_t];
    int          byCls[Grain];
    function int one(); return 1; endfunction
  endclass

  class Bin134;
    Grain dyn[];         // dynamic of class
    Grain que[$];        // queue of class
    Grain fix[3];        // fixed of class
    Grain asStr[string]; // assoc keyed by string
    Grain asInt[int];    // assoc keyed by int
    Grain asEnu[ekey134_t];
    Grain asCls[Grain];

    function void kdyn();  foreach (dyn[u1])  foreach (dyn[u1].gi[v1])   $display(v1); endfunction
    function void kque();  foreach (que[u2])  foreach (que[u2].gs[v2])   $display(v2); endfunction
    function void kfix();  foreach (fix[u3])  foreach (fix[u3].gb[v3])   $display(v3); endfunction
    function void kstr();  foreach (asStr[u4]) foreach (asStr[u4].byStr[v4]) $display(v4); endfunction
    function void kint();  foreach (asInt[u5]) foreach (asInt[u5].byInt[v5]) $display(v5); endfunction
    function void kenu();  foreach (asEnu[u6]) foreach (asEnu[u6].byEnum[v6]) $display(v6); endfunction
    function void kcls();  foreach (asCls[u7]) foreach (asCls[u7].byCls[v7]) $display(v7); endfunction
    function void kgra();  foreach (dyn[u8])  foreach (dyn[u8].gr[v8])   $display(v8); endfunction
  endclass

endpackage
