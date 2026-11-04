// § pkgAliasTdRefNameByParent284
package pk;
  typedef enum logic [3:0] { E0, E1 } b_t;
  typedef b_t a_t;
endpackage
module dut import pk::*; (input a_t i, output logic [3:0] o);
  assign o = i;
endmodule
