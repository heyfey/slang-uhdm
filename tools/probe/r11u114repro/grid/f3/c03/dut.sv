// two-hop, header import into the module
package pa;
  localparam logic [31:0] A_CAT = {1'b0, 31'd22};
endpackage
package pb;
  import pa::*;
  localparam logic [31:0] B_CAT = {1'b1, 31'd7};
endpackage
module top import pb::*; (input logic [31:0] x, output logic y);
  assign y = (x == B_CAT);
endmodule
