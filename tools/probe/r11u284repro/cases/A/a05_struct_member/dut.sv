// § pkgAliasTdRefNameByParent284
package pk;
  typedef struct packed { logic [1:0] x; logic [1:0] y; } b_t;
  typedef b_t a_t;
  typedef struct packed { a_t f; logic v; } s_t;
endpackage
module dut(input pk::s_t s, output logic o);
  assign o = ^s;
endmodule
