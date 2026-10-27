// § modClassTdListing442
class C;
endclass
typedef C c_t;
module top;
  function automatic void f();
    c_t l [$];
    C k [$];
  endfunction
endmodule
