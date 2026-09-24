package p;
  class c;
    int prop;
    function void sink(int a);
    endfunction
    extern function void oob(int f);
    function void inl(int f);
      int loc;
      sink(f);
      sink(loc);
    endfunction
  endclass
  function void c::oob(int f);
    int loc;
    sink(f);
    sink(loc);
  endfunction
endpackage

module top;
  p::c h;
  initial h.inl(1);
endmodule
