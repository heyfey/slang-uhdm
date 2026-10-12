// § rawEndLineModel295
`define V(x) x
module dut (output logic [7:0] o);
  logic [7:0] ma = `V(8'h7);
  assign o = ma;
endmodule
