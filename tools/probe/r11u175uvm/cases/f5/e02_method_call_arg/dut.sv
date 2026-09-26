package p1;
  class wrap;
    function wrap create_object(string name); return null; endfunction
  endclass
  class factory;
    function wrap create_by_name(string name, wrap wrapper);
      return wrapper.create_object(name);
    endfunction
  endclass
endpackage
module top;
  import p1::*;
  factory f;
  initial begin f = new; void'(f.create_by_name("a", null)); end
endmodule
