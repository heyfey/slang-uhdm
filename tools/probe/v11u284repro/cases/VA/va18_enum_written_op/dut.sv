// § pkgAliasTdRefNameByParent284
package pk;
  typedef enum logic [1:0] { E0, E1, E2 } b_t;
  typedef b_t a_t;
endpackage
module dut(input logic s, output logic [1:0] o);
  pk::a_t z;
  assign z = s ? pk::E1 : pk::E2;
  assign o = z;
endmodule
