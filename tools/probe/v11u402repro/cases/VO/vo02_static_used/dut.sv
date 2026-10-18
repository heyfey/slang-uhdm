// § unitOobFuncOnDesign402
class c;
  extern static function int g(int x);
endclass
function int c::g(int x); return x + 1; endfunction
module top;
  int r;
  initial r = c::g(3);
endmodule
