// § dynAssocMemberSpanToDim295
package pk;
  typedef struct {string args[]; int used;} cfg_t;
  cfg_t gcfg;
endpackage
module dut (output int o);
  import pk::*;
  assign o = 0;
endmodule
