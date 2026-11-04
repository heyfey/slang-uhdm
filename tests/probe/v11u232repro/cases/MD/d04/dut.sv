// § defAggParamBindsImportClone232
// a bare struct typed parameter of an interface and of a module two levels down, passed down by name
package p;
  typedef struct packed { logic [3:0] a; logic b; } t_t;
endpackage
interface ifc import p::*; #(parameter t_t T = '{a: 4'd1, b: 1'b0});
  logic [T.a-1:0] v;
endinterface
module leaf import p::*; #(parameter t_t T = '0) (output logic [4:0] o);
  assign o = T;
endmodule
module mid import p::*; #(parameter t_t T = '0) (output logic [4:0] o);
  leaf #(.T(T)) l (.o(o));
endmodule
module top(output logic [4:0] o);
  ifc #(.T(5'b00111)) i ();
  mid #(.T(5'b01111)) m (.o(o));
endmodule
