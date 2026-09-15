interface iface (input logic clk);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
endinterface
module dut (input logic clk, output logic [7:0] b_o);
  iface i0 (.clk(clk));
  assign b_o = i0.I.x;
endmodule
