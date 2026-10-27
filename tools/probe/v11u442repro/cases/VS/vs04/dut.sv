// § unitClassTdEndAtDim442
class C;
endclass
typedef C u_t;
module top;
  u_t b = null;
  u_t a [4];
  function void f(); u_t z [2]; endfunction
endmodule
