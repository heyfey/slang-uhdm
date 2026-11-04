// § rawEndLineModel295
package pk;
  typedef struct packed { logic [3:0] \m.a ; logic [3:0] b; } s_t;
endpackage
module dut (output logic [3:0] o);
  pk::s_t s;
  assign s = '0;
  assign o = s.b;
endmodule
