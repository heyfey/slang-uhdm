// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
package pc;
  class C;
    pk::a_t m;
  endclass
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
