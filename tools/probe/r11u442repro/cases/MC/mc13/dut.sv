// § modClassTdListing442
class C;
endclass
module top;
  typedef C c_t;
  c_t a2 [2][3];
  function automatic void f();
    c_t l [4];
  endfunction
endmodule
