// r10uvm150 arm D — do the ROOT CALL's OWN ARGUMENTS survive the chain?
// Arg counts 0..3, three homes (in-body / OUT-OF-BODY / free function),
// three instances on one line, and the this./super. root with arguments.
package dpk;
  class tgt_9;
    int w = 2;
    function int twice(int m); return w*m; endfunction
    function int none(); return w; endfunction
  endclass

  class src_9;
    extern static function tgt_9 mk0();
    extern static function tgt_9 mk1(int p);
    extern static function tgt_9 mk3(int p, int q, int r);
    function tgt_9 own1(int p); tgt_9 t = new(); t.w = p; return t; endfunction
    extern function int  oob_home();
    function int in_home(); return src_9::mk1(11).twice(12); endfunction
    function int this_arg(); return this.own1(13).twice(14); endfunction
    function int this_noarg(); return this.own1(15).none(); endfunction
    function tgt_9 plain_this(); return this.own1(16); endfunction
  endclass
  function tgt_9 src_9::mk0();                       tgt_9 t = new();               return t; endfunction
  function tgt_9 src_9::mk1(int p);                  tgt_9 t = new(); t.w = p;      return t; endfunction
  function tgt_9 src_9::mk3(int p, int q, int r);    tgt_9 t = new(); t.w = p+q+r;  return t; endfunction
  function int src_9::oob_home(); return src_9::mk3(1,2,3).twice(4); endfunction

  function tgt_9 dmk(int p); tgt_9 t = new(); t.w = p; return t; endfunction
endpackage

module topd;
  import dpk::*;
  int y0,y1,y2,y3;
  // D1  scoped binding root, ONE argument, then a chain
  function int d1(); return src_9::mk1(21).twice(22); endfunction
  // D2  the same root STANDALONE (argument + span control)
  function automatic tgt_9 d2(); return src_9::mk1(21); endfunction
  // D3  scoped binding root, THREE arguments, then a chain
  function int d3(); return src_9::mk3(31,32,33).twice(34); endfunction
  // D4  scoped binding root, ZERO arguments, then a chain
  function int d4(); return src_9::mk0().twice(41); endfunction
  // D5  BARE package function root with one argument, then a chain
  function int d5(); return dmk(51).twice(52); endfunction
  // D6  the same bare root STANDALONE (span control)
  function automatic tgt_9 d6(); return dmk(51); endfunction
  // D7  THREE instances, arg counts 0/1/3, one expression
  function int d7(); return src_9::mk0().none() + src_9::mk1(71).none() + src_9::mk3(72,73,74).none(); endfunction
  // D8  statement position, three-argument root
  task d8(); src_9::mk3(81,82,83).twice(84); endtask
  initial begin
    y0 = d1(); y1 = d3(); y2 = d5(); y3 = d7();
    d8();
  end
endmodule
