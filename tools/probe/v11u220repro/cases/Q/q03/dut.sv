// § pkgQualOperandSpanInParam218
package p; localparam int A = 3; endpackage
module sub #(parameter int W = p::A - 1) (output logic [W:0] o);
  assign o = '1;
endmodule
module top(output logic [2:0] o, output logic [4:0] q);
  sub u(.o(o));
  sub #(.W(4)) v(.o(q));
endmodule
