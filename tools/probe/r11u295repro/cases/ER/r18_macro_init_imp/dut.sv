// § rawEndLineModel295
`define INIT 8'h5
package pk;
  logic [7:0] vz = `INIT;
endpackage
module dut (output logic [7:0] o);
  import pk::*;
  assign o = vz;
endmodule
