// § classTpDefaultTsAtUse180
package pkg;
  class base_c; endclass
  class holder #(type CB=base_c);
    CB m;
  endclass
  class child #(type CB=base_c) extends holder #(CB);
    CB n;
    function void f();
      CB l;
      l = n;
    endfunction
  endclass
endpackage
module top();
pkg::child c1;
endmodule
