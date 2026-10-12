// § rawEndLineModel295
package pk;
  logic [7:0] vs = 8'h 5;
endpackage
module dut (output logic [7:0] o);
  import pk::*;
  logic [7:0] ns = 8'h 6;
  assign o = vs ^ ns;
endmodule
