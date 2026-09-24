// r10v133 arm C - the SIBLING query functions over a CALL in a MODULE (not a
// class): the control that proves the law is $bits-only.  MEASUREMENT ONLY.
module vm133c;
  int    cq[$];
  bit [7:0] ca [4];
  bit [3:0][7:0] cm;
  bit [15:0] cv;
  int    r;
  function automatic int cf133(); return 4; endfunction
  initial begin
    r = $bits(cf133());          // S01 the law
    r = $bits(cq.size());        // S02 the law
    r = $size(cf133());          // S03
    r = $size(cq.size());        // S04
    r = $size(cm, 1);            // S05 control, dim index
    r = $clog2(cf133());         // S06
    r = $clog2(cq.size());       // S07
    r = $high(cf133());          // S08
    r = $low(cf133());           // S09
    r = $left(cf133());          // S10
    r = $right(cf133());         // S11
    r = $dimensions(cf133());    // S12
    r = $unpacked_dimensions(cf133()); // S13
    r = $increment(cf133());     // S14
    r = $clog2($bits(cf133()));  // S15 sibling OVER the law
    r = $bits($clog2(cf133()));  // S16 the law over a sibling
    r = $bits($size(ca));        // S17 the law over a sibling (no user call)
    r = $bits($signed(cv));      // S18 the law over $signed
    r = $bits($unsigned(cv));    // S19 the law over $unsigned
    r = $size(ca);               // S20 control
    r = $clog2(16);              // S21 control
    if (r == 0) r = 1;
  end
endmodule
