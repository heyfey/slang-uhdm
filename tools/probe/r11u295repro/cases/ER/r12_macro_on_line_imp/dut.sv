// § rawEndLineModel295
`define W 8
`define INIT 8'h5
package pk;
  logic [`W-1:0] vz = `INIT;
  logic [`W-1:0] varr [0:1];
endpackage
module dut (output logic [7:0] o);
  import pk::*;
  assign o = vz;
endmodule
