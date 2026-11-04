// § defAggParamBindsImportClone232
// header imports, a bare struct parameter passed down two levels by name, literal overrides, no interface
package p;
  typedef struct packed { logic [3:0] a; logic b; } t_t;
endpackage
module leaf import p::*; #(parameter t_t T = '0) (output logic [4:0] o);
  assign o = T;
endmodule
module mid import p::*; #(parameter t_t T = '0) (output logic [4:0] o);
  leaf #(.T(T)) l (.o(o));
endmodule
module top(output logic [4:0] o, output logic [4:0] q);
  mid #(.T(5'b01111)) m (.o(o));
  mid n (.o(q));
endmodule
