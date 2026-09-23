// two-hop: a packed-array parameter written as a vector pattern, and a 2-D packed concat
package pa;
  parameter logic [3:0][1:0] VPAT = '{2'd0, 2'd1, 2'd2, 2'd3};
  parameter logic [1:0][3:0] MCAT = {4'h1, 4'h2};
endpackage
package pb;
  import pa::*;
  parameter int B_W = 3;
endpackage
module top (input logic [31:0] x, output logic y);
  import pb::*;
  assign y = x[0];
endmodule
