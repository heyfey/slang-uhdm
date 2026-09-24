// r10uvm123 arm A — a package CLASS's method casts to the package's own
// vector typedefs, in-body and out-of-body.  The head's own topology.
`define WIDA123 24
package alder123_pkg;
  typedef bit   [`WIDA123-1:0] Bark_bt;
  typedef logic [`WIDA123-1:0] bark_lt;
  typedef bit   [11:0]         BARK_PLAIN;
  typedef enum bit [2:0] { AL_ONE = 3'd1, AL_TWO = 3'd2 } bark_et;
  typedef struct packed { bit [3:0] q; bit r; } bark_st;

  class Alder123;
    Bark_bt    m_b;
    bark_lt    m_l;
    BARK_PLAIN m_p;
    bark_et    m_e;
    bark_st    m_s;
    function bit inbody(int v);
      m_b = Bark_bt'(v);
      m_l = bark_lt'(v);
      m_p = BARK_PLAIN'(v);
      m_e = bark_et'(v);
      return 1'b1;
    endfunction
    extern function int oob(int v);
  endclass

  function int Alder123::oob(int v);
    m_b = Bark_bt'(v);
    m_l = bark_lt'(v);
    m_p = BARK_PLAIN'(v);
    m_e = bark_et'(v);
    return 7;
  endfunction
endpackage

module alder123_top;
  import alder123_pkg::*;
  Alder123 h;
  initial h = new();
endmodule
