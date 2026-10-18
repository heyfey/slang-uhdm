// § unitOobDefsNotInClass402
class c;
  int v;
  extern function new(int x);
endclass
function c::new(int x); v = x; endfunction
module top;
  c o = new(3);
endmodule
