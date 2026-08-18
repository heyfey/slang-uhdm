// r10uvm95 grid D — the OUT-OF-BLOCK body: what exactly does it keep?
package pE95;
  typedef bit [63:0] wide95_t;
  localparam int PW95 = 9;
  class oob95;
    typedef bit [23:0] own95_t;
    byte      b1;
    byte      ba [4];
    extern function void go(int i);
    function void inb(int i);
      int r;
      r = $bits(byte);
      r = $bits(int);
      r = $bits(own95_t);
      r = $bits(wide95_t);
      r = $bits(b1);
      r = $clog2(9);
      r = $clog2(PW95);
      r = 2 + 3;
      r = PW95 * 2;
      if (r > 0) r = 0;
    endfunction
  endclass
  function void oob95::go(int i);
    int r;
    r = $bits(byte);
    r = $bits(int);
    r = $bits(own95_t);
    r = $bits(wide95_t);
    r = $bits(b1);
    r = $clog2(9);
    r = $clog2(PW95);
    r = 2 + 3;
    r = PW95 * 2;
    if (r > 0) r = 0;
  endfunction
endpackage
