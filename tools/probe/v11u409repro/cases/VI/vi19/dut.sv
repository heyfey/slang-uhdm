// § tdCloneQualNameAbstain409v
package p;
  typedef logic [3:0] ft_t;
endpackage
module top #(parameter p::ft_t W = 4'd3) (output [3:0] o);
  assign o = W;
endmodule
