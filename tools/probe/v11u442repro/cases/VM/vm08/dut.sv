// § modClassTdListing442
class C;
endclass
module top;
  typedef C c_t;
  c_t h;
  function automatic void f();
    c_t loc [2];
  endfunction
  generate if (1) begin : g
    c_t gh;
  end endgenerate
endmodule
