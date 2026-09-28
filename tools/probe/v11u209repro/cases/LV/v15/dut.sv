// § tfItemInitLocalAtType209: a static local with an initializer in a paren-less function in an interface
interface ifc;
  function int f;
    static int cnt = 7;
    return cnt;
  endfunction
endinterface
module top;
  ifc i();
  int r;
  initial r = i.f();
endmodule
