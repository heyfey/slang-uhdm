// vbuvm19 — the last shape cells: struct-keyed assoc, unpacked struct array,
// multi-dim unpacked, and a 3-D mixed array.
package vmp19;
  typedef struct packed { bit [3:0] a19; bit [3:0] b19; } sk19;
  typedef struct { int x19; int y19; } su19;
  class vm19;
    int  ms19[sk19];        // associative keyed by a packed STRUCT
    su19 mu19[4];           // unpacked array of UNPACKED struct
    int  m3d19[2][3][4];    // three dimensions
    int  mq19[$][string];   // queue of associative
    extern function void sksel19();
    extern function void susel19();
    extern function void d3sel19();
    extern function void mqsel19();
  endclass
  function void vm19::sksel19();
    sk19 k19;
    foreach (ms19[i]) $display("sk", ms19[i]);
    ms19[k19] = 1;
  endfunction
  function void vm19::susel19();
    foreach (mu19[i]) $display("su", mu19[i].x19);
    mu19[1] = '{0,0};
  endfunction
  function void vm19::d3sel19();
    foreach (m3d19[i,j,k]) $display("d3", m3d19[i][j][k]);
    m3d19[1][2][3] = 7;
  endfunction
  function void vm19::mqsel19();
    foreach (mq19[i]) $display("mq");
    mq19[0]["z"] = 8;
  endfunction
endpackage
