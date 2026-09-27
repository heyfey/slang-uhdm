// § tfArgClassMethodOrder176 § refFullNameThroughNamedExpr175
package pa;
  localparam int W = 5;
  typedef enum logic [1:0] {A, B, C} e_t;
  localparam e_t DEF = B;
endpackage
package pb;
  import pa::*;
  class k;
    function void put(e_t e = pa::DEF, int n = pa::W);
    endfunction
    function void get(e_t e = DEF, int n = W + 1);
    endfunction
  endclass
endpackage
module top;
  import pb::*;
  k o;
  initial begin o = new; o.put(); o.get(); end
endmodule
