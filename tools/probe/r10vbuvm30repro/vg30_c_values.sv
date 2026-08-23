package pv30c;
  class cv30c;
    int m;
    logic [63:0] w;
    extern function int c_zero();
    extern function int c_wide64();
    extern function int c_wide64d();
    extern function int c_unk();
    extern function int c_s8();
    extern function int c_bin();
    extern function int c_oct();
    extern function int c_s32min();
    extern function int c_bit1();
    extern function int c_h12();
    extern function int c_unsized();
    extern function int c_underscore();
  endclass
  function int cv30c::c_zero();       return (m == -0);                     endfunction
  function int cv30c::c_wide64();     return (w == -64'hFFFFFFFFFFFFFFFF);  endfunction
  function int cv30c::c_wide64d();    return (w == -64'd9223372036854775808); endfunction
  function int cv30c::c_unk();        return (m == -4'b1x01);               endfunction
  function int cv30c::c_s8();         return (m == -8'sd128);               endfunction
  function int cv30c::c_bin();        return (m == -'b1);                   endfunction
  function int cv30c::c_oct();        return (m == -'o7);                   endfunction
  function int cv30c::c_s32min();     return (m == -32'sh80000000);         endfunction
  function int cv30c::c_bit1();       return (m == -1'b1);                  endfunction
  function int cv30c::c_h12();        return (m == -12'h800);               endfunction
  function int cv30c::c_unsized();    return (m == -'d1);                   endfunction
  function int cv30c::c_underscore(); return (m == -1_000);                 endfunction
endpackage
