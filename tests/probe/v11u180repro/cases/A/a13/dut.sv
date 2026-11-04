// § classTpDefaultTsAtUse180 (verifier: a derived class re-declaring the same type parameter name)
package pkg;
  class base_c; endclass
  class other_c; endclass
  class holder #(type CB=base_c);
    CB m;
  endclass
  class der #(type CB=other_c) extends holder #(CB);
    CB n;
    function void g(CB y); n = y; endfunction
  endclass
endpackage
module top();
pkg::der d1;
endmodule
