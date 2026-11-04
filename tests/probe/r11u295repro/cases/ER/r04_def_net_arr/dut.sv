// § rawEndLineModel295
module dut (input logic [7:0] i, output logic [7:0] o);
  logic [7:0] \n.x [0:1];
  assign \n.x [0] = i;
  assign o = \n.x [0];
endmodule
