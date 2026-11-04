// § pkgAliasTdRefNameByParent284
package pk;
  typedef struct packed { logic [1:0] x; logic [1:0] y; } b_t;
  typedef b_t a_t;
endpackage
module sub #(parameter pk::a_t M = '0) (output logic [3:0] o);
  assign o = M;
endmodule
module dut(output logic [3:0] o);
  sub #(.M(4'd5)) u (.o(o));
endmodule
