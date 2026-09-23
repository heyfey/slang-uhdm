// two-hop: pa's params reach the module only through pb's `import pa::*` (Surelog leak)
package pa;
  typedef enum logic [6:0] { OP_SYS = 7'h73 } op_e;
  localparam logic [31:0] A_CAT = {1'b0, 31'd22};
  parameter logic [31:0] A_ENUM = {25'h0, {OP_SYS}};
  parameter logic [31:0] A_LIT = 32'h16;
  localparam logic [7:0] A_ONE = {8'h5A};
endpackage
package pb;
  import pa::*;
  parameter logic [31:0] B_CAT = {1'b1, 31'd7};
  parameter logic [31:0] B_ENUM = {25'h1, {OP_SYS}};
endpackage
module top (input logic [31:0] x, output logic y);
  import pb::*;
  assign y = (x == B_CAT);
endmodule
