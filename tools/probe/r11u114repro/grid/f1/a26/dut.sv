// unpacked-array package parameter, positional pattern with a concat element
package q2;
  localparam logic [7:0] ARR [2] = '{ {4'h1, 4'h2}, 8'h3 };
endpackage
module top(output logic o);
  assign o = 1'b0;
endmodule
