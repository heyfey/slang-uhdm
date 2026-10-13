// § defGenModArraySizeRange309
package pk;
  localparam int N = 2;
endpackage
module leaf (input logic i, output logic o);
  assign o = ~i;
endmodule
module top (input logic [1:0] i, output logic [1:0] o);
  if (1) begin : g
    leaf l [pk::N] (.i(i), .o(o));
  end
endmodule
