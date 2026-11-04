// § classTdRetVarAtTypeToken412
class C;
  typedef logic [3:0] nib_t;
  typedef int i_t;
  function nib_t f(); return 4'd1; endfunction
  function i_t g(); return 2; endfunction
endclass
module top;
  C c;
endmodule
