// § rawEndLineModel295
package pk;
  logic [7:0] \v.arr [0:1];
  logic [1:0][3:0] \v.pk ;
endpackage
module dut (output logic [7:0] o);
  import pk::*;
  assign o = \v.arr [0];
endmodule
