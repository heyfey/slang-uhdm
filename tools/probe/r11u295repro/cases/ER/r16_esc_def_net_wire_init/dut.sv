// § rawEndLineModel295
module dut (output logic [7:0] o);
  wire [7:0] \w.y = 8'h3;
  logic [7:0] \n.v [0:1] = '{8'h1, 8'h2};
  assign o = \w.y ^ \n.v [0];
endmodule
