// § impPaLhsDisjointClone133
package pa;
   parameter int NDioPads = 24;
endpackage
package pb;
   import pa::*;
   typedef struct packed {
      logic [NDioPads-1:0] pads;
   } cfg_t;
endpackage
module top(output int o);
   pb::cfg_t c;
   assign c = '0;
   assign o = $bits(c);
endmodule
