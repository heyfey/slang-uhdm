// one-hop: the module imports pa directly
package pa;
  typedef enum logic [6:0] { OP_SYS = 7'h73 } op_e;
  localparam logic [31:0] A_CAT = {1'b0, 31'd22};
  parameter logic [31:0] A_ENUM = {25'h0, {OP_SYS}};
  localparam logic [7:0] A_ONE = {8'h5A};
endpackage
module top (input logic [31:0] x, output logic y);
  import pa::*;
  assign y = (x == A_CAT);
endmodule
