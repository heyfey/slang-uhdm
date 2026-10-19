// § classTdRetVarAtTypeToken412
class C;
  typedef string S;
  typedef real R;
  typedef byte B;
  typedef logic L;
  function S fs(); return "a"; endfunction
  function R fr(); return 1.0; endfunction
  extern function B fb();
  extern function L fl();
endclass
function C::B C::fb(); return 8'd1; endfunction
function C::L C::fl(); return 1'b1; endfunction
module top; endmodule
