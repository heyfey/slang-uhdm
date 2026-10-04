// § defAggParamBindsImportClone232
// d03 with the interface override a literal and mid keeping its pattern override
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
  mid #(.T('{a: 4'd7, b: 1'b1})) m (.o(o));
endmodule
