// r10v95 arm b10 — $unit scope, new[] sizes, foreach/constraint carriers,
// stream slices, wide (>64-bit) roots, 2-state vs 4-state.
logic [200:0] gWide;
byte          gDyn [];
int           gFix [7];
typedef bit [40:0] gb41_t;
gb41_t        gArr [2];

class Csz;
  rand int unsigned m_n;
  byte  m_buf [];
  int   m_tab [4];
  constraint c_n { m_n < $bits(m_tab[1]); }
  function void go();
    m_buf = new [$bits(m_tab[2])];
    foreach (m_tab[k]) m_n = m_n + $bits(m_tab[k]);
  endfunction
endclass

module b10;
  bit  [65:0]  w66;
  logic [80:0] w81;
  byte         st [];
  int          o [24];
  initial begin
    o[0]  = $bits(gWide[3]);
    o[1]  = $bits(gWide[100:9]);
    o[2]  = $bits(gDyn[1]);
    o[3]  = $bits(gFix[2]);
    o[4]  = $bits(gArr[1]);
    o[5]  = $bits(gArr[1][7]);
    o[6]  = $bits(w66[2]);
    o[7]  = $bits(w81[70:5]);
    o[8]  = $bits(st[0]);
    o[9]  = $bits(w66);
    o[10] = $bits(gb41_t);
  end
endmodule
