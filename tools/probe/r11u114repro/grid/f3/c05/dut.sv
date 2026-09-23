// diamond: the module imports pa directly AND through pb
package pa;
  localparam logic [31:0] A_CAT = {1'b0, 31'd22};
  parameter logic [7:0] AddrRst[2] = '{ 8'h0, 8'h1 };
endpackage
package pb;
  import pa::*;
  localparam logic [31:0] B_CAT = {1'b1, 31'd7};
endpackage
module top (input logic [31:0] x, output logic y);
  import pa::*;
  import pb::*;
  assign y = x[0];
endmodule
