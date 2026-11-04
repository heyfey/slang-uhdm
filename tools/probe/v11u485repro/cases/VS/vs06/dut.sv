// § clsOvSpanSepEnd485
class K; parameter w = 5; endclass
`define KW K :: w
module m #(parameter A = 4) (output logic [7:0] o);
  assign o = 8'd0;
endmodule
module top; logic [7:0] o; m #(.A(`KW)) u(o); endmodule
