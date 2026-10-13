// § defGenOrderedConnPorts307
package pk; localparam logic C = 1'b1; endpackage
module leaf (input logic i); endmodule
module outer (input logic a, b);
  if (1) begin : g
    leaf u_x (a & b);
    leaf u_y (pk::C);
    leaf u_z (1'b0);
  end
endmodule
module dut (input logic a, b);
  outer u1 (.a(a), .b(b));
endmodule
