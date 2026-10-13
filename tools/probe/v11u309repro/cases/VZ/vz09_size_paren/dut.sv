// § defGenModArraySizeRange309
module leaf (input logic i, output logic o);
  assign o = ~i;
endmodule
module top #(parameter int N = 2) (input logic [3:0] i, output logic [3:0] o);
  if (1) begin : g
    leaf l [(N*2)] (.i(i), .o(o));
  end
endmodule
