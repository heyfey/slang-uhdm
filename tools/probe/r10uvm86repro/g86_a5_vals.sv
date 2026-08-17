// r10uvm86 arm a5 — the VALUE/SIZE table of the folded constant, and the
// POSITIVE controls that fix the standalone-literal sizes the fold reuses.
package p5;
  function int f_neg0();    return -0; endfunction
  function int f_neg2b10(); return -2'b10; endfunction
  function int f_neg4hF();  return -4'hF; endfunction
  function int f_neg8d200();return -8'd200; endfunction
  function int f_neg32hF(); return -32'hFFFFFFFF; endfunction
  function int f_neg64d1(); return -64'd1; endfunction
  function int f_neg1sb1(); return -1'sb1; endfunction
  function int f_neg3o7();  return -3'o7; endfunction
  function int f_negund();  return -1_0; endfunction
  function int p_plain();   return 1; endfunction
  function int p_8d3();     return 8'd3; endfunction
  function int p_1b1();     return 1'b1; endfunction
  function int p_d1();      return 'd1; endfunction
  function int p_h10();     return 'h10; endfunction
  function int p_2b10();    return 2'b10; endfunction
  function int p_4hF();     return 4'hF; endfunction
  function int p_8d200();   return 8'd200; endfunction
  function int p_32hF();    return 32'hFFFFFFFF; endfunction
  function int p_64d1();    return 64'd1; endfunction
  function int p_0();       return 0; endfunction
  function int p_1sb1();    return 1'sb1; endfunction
  function int p_3o7();     return 3'o7; endfunction
  function int f_neg2sb10();return -2'sb10; endfunction
  function int f_neg4sd8();  return -4'sd8; endfunction
  function int f_neg8sh80(); return -8'sh80; endfunction
  function int p_2sb10();   return 2'sb10; endfunction
  function int p_4sd8();    return 4'sd8; endfunction
  function int p_8sh80();   return 8'sh80; endfunction
endpackage
