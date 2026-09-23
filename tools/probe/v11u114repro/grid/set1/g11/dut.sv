// face-1 break: concat member read unqualified via wildcard import, in a module that also reads it in a case item
package q2;
  
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {6'h15, 6'h2A}, cfg: 2'b11 };
endpackage
module top import q2::*; (input logic [11:0] x, output logic y); always_comb case (x) IMPL.v: y = 1; default: y = 0; endcase endmodule
