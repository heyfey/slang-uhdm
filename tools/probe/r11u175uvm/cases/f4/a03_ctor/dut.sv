package p1;
  class base;
    string nm;
    extern function new(string name = "x", base parent = null);
  endclass
  function base::new(string name = "x", base parent = null);
    nm = name;
  endfunction
endpackage
module top;
  import p1::*;
  base b;
  initial b = new("y");
endmodule
