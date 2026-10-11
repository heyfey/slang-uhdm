// § pkgAliasTdRefNameByParent284
package pk;
  typedef enum logic [3:0] { E0, E1 } b_t;
  typedef b_t a_t;
  a_t pv;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = i ^ pk::pv;
endmodule
