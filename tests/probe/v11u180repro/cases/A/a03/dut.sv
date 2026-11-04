// § classTpDefaultTsAtUse180 (verifier: the default is a parameterized class)
package pkg;
  class base_c #(int N = 1); int v; endclass
  class holder #(type CB=base_c#(8));
    CB m;
    function void g();
      CB loc;
      loc = m;
    endfunction
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
