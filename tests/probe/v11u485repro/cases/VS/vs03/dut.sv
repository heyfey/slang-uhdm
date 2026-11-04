// § clsOvSpanSepEnd485
package p; class K; parameter w = 5; endclass endpackage
module m #(parameter A = 4) (output logic [7:0] o);
  assign o = 8'd0;
endmodule
module top; logic [7:0] o; m #(.A(p :: K :: w)) u(o); endmodule
