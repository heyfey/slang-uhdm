// § modClassTdListing442
class C;
endclass
module top;
  typedef C c_t;
  function automatic int f();
    c_t l;
    return 0;
  endfunction
endmodule
