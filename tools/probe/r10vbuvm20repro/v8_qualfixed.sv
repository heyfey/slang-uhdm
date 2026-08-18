// v8: package-QUALIFIED written return type whose typedef range is ALREADY a
// constant -- so the fold axis cannot mask a name/alias regression.
package vp8;
  typedef logic signed [7:0]  l8_t;    // fixed range, no parameter
  typedef logic [15:0]        l16_t;
  typedef logic               l1_t;

  class C8;
    extern function vp8::l8_t  q8();
    extern function vp8::l16_t q16();
    extern function vp8::l1_t  q1();
    extern function l8_t       b8();    // bare, for contrast
  endclass
  function vp8::l8_t  C8::q8();  q8  = 'b0; endfunction
  function vp8::l16_t C8::q16(); q16 = 'b0; endfunction
  function vp8::l1_t  C8::q1();  q1  = 'b0; endfunction
  function l8_t       C8::b8();  b8  = 'b0; endfunction

  function vp8::l8_t free_q8(); free_q8 = 'b0; endfunction
  function l8_t      free_b8(); free_b8 = 'b0; endfunction
endpackage

module vt8;
  import vp8::*;
  vp8::l8_t w; vp8::C8 c;
  initial begin c = new(); w = c.q8(); end
endmodule
