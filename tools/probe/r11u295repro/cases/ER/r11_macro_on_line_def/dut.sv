// § rawEndLineModel295
`define W 8
`define INIT 8'h5
module dut (output logic [7:0] o);
  logic [`W-1:0] nz = `INIT;
  assign o = nz;
endmodule
