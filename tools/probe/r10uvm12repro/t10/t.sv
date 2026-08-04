package p;
  class c;
    int prop;
    function void sink(int a);
    endfunction
    function void probe(int f);
      int loc;
      loc = f;
      f = loc;
      prop = f;
      sink(f);
      sink(loc);
      sink(prop);
      if (f) loc = 1;
      if (loc) f = 1;
      if (prop) loc = 2;
      case (f) 1: loc = 3; default: loc = 4; endcase
      for (int i = 0; i < f; i++) loc = i;
      loc = f + prop;
    endfunction
  endclass
endpackage

module top;
  p::c h;
  initial h.probe(1);
endmodule
