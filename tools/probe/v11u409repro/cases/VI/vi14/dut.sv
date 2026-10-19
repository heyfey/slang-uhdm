// § tdCloneQualNameAbstain409v
package p;
  typedef bit [3:0] ft_t;
endpackage
module top (output [3:0] o);
  parameter p::ft_t W = 4'd3;
  assign o = W;
endmodule
