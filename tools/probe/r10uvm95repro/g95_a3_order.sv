// r10uvm95 grid C — member-vs-select ORDER, deeper chains, type names in a
// class, and the sibling type queries.  One call per line.
package pC95;
  typedef struct packed { bit [11:0] hi; bit [3:0] lo; } sp95_t;
  typedef bit [5:0] tsix95_t;
  typedef struct { sp95_t s; byte a[4]; bit [15:0] w; } su95_t;   // unpacked struct
  typedef bit [63:0] wide95_t;
endpackage

module mC95(output int o);
  import pC95::*;
  su95_t     us;
  sp95_t     sp;
  sp95_t     spa [3];
  byte       ba  [4];
  bit [7:0]  pk  [2][3];
  int r;
  initial begin
    r = $bits(us.a);
    r = $bits(us.a[1]);
    r = $bits(us.s);
    r = $bits(us.s.hi);
    r = $bits(us.w[3:0]);
    r = $bits(spa[1].hi);
    r = $bits(pk[1]);
    r = $bits(pk[1][2]);
    r = $bits(pk[1][2][4]);
    r = $bits(tsix95_t);
    r = $bits(wide95_t);
    r = $size(ba);
    r = $size(ba[1]);
    r = $size(pk);
    r = $size(pk[1]);
    r = $clog2(ba[1]);
    r = $high(ba);
    r = $high(ba[1]);
    r = $low(ba[1]);
    r = $left(ba[1]);
    r = $right(ba[1]);
    r = $dimensions(ba[1]);
    r = $unpacked_dimensions(ba[1]);
    r = $increment(ba[1]);
    o = r;
  end
endmodule

package pD95;
  typedef bit [63:0] wide95_t;
  typedef struct packed { bit [11:0] hi; bit [3:0] lo; } sp95_t;
  class kls95;
    typedef bit [23:0] own95_t;
    byte      b1;
    byte      ba [4];
    sp95_t    sp;
    sp95_t    spa [3];
    function void go(int i);
      int r;
      r = $bits(own95_t);
      r = $bits(wide95_t);
      r = $bits(sp95_t);
      r = $bits(byte);
      r = $bits(sp.hi);
      r = $bits(spa[i].hi);
      r = $bits(ba[i]);
      r = $size(ba);
      r = $size(ba[i]);
      r = $clog2(b1);
      if (r > 0) r = 0;
    endfunction
  endclass
  // OUT-OF-BLOCK body: uvm_reg_block::check_data_width's shape
  class kls2_95;
    byte b1;
    byte ba [4];
    extern function void go2(int i);
  endclass
  function void kls2_95::go2(int i);
    int r;
    r = $bits(wide95_t);
    r = $bits(b1);
    r = $bits(ba[i]);
    if (r > 0) r = 0;
  endfunction
endpackage
