package p;
  class other;
    function void om(int a);
    endfunction
  endclass
  class c;
    int prop;
    other o;
    function void sink(int a);
    endfunction
    function void probe(int f);
      int loc;
      o.om(f);
      o.om(loc);
      o.om(prop);
      $display("%0d", f);
      $display("%0d", loc);
      $display("%0d", prop);
      sink(f + loc);
      sink(-f);
      sink({f, loc});
    endfunction
  endclass
endpackage

module top;
  p::c h;
  initial h.probe(1);
endmodule
