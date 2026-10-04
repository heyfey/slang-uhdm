// § defAggParamBindsImportClone232
// body imports (the struct_param_func_config placement), a bare struct parameter passed down by name, literal and defaulted instances
package p;
  typedef struct packed { logic [3:0] a; logic b; } t_t;
endpackage
module leaf #(parameter int W = 1) (output logic [W-1:0] o);
  assign o = '0;
endmodule
module mid (output logic [4:0] o);
  import p::*;
  parameter t_t T = '0;
  leaf #(.W(T.a + 1)) l (.o(o));
endmodule
module top(output logic [7:0] o, output logic [0:0] q);
  mid #(.T(5'b01111)) m (.o(o));
  mid n (.o(q));
endmodule
