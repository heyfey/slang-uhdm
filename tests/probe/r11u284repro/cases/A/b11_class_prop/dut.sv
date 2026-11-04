// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(output logic [3:0] o);
  class C;
    pk::a_t m;
  endclass
  assign o = '0;
endmodule
