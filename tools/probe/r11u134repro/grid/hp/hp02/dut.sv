// § tsHierPathElemNoName134
package p;
   typedef struct packed { int XLEN; } cfg_t;
   localparam cfg_t Cfg = '{XLEN: 8};
endpackage
module top(output logic [7:0] o);
   typedef logic [p::Cfg.XLEN-1:0] w_t;
   w_t v;
   assign v = '0;
   assign o = v;
endmodule
