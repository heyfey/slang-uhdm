// § tfArgClassMethodOrder176 § tfArgQualOutsideWriter176
package pa;
  typedef enum logic [2:0] {X0, X1, X2} e_t;
endpackage
package pb;
  import pa::*;
  class k;
    function void m(pa::e_t v); endfunction
    function void n(e_t w); endfunction
  endclass
endpackage
module top;
  import pb::*;
  k o;
  initial begin o = new; o.m(pa::X1); o.n(pa::X2); end
endmodule
