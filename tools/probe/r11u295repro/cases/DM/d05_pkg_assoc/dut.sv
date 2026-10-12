// § dynAssocMemberSpanToDim295
package pk;
  typedef struct {string args[string]; int used;} cfg_t;
endpackage
module dut (output int o);
  pk::cfg_t c;
  assign o = 0;
endmodule
