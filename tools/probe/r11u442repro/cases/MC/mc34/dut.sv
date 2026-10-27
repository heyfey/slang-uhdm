// § modDynArrClsTdElemClassVar442
class C;
endclass
module top;
  typedef C c_t;
  c_t a [int];
  function automatic void f();
    c_t l [$];
  endfunction
endmodule
