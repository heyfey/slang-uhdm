// § psBoundPaOwnerName192 § procPsBoundOwner192
package pa;
  parameter int unsigned WA = 3;
endpackage
package pb;
  localparam int unsigned WB = $clog2(32);
endpackage
module sub import pa::*; import pb::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  assign y1 = x[WA:0];
  assign y2 = x[WB:WA];
  always_comb y3 = {x[31:WB], x[WA:0]};
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] z1);
  import pb::*;
  sub u (.*);
  assign z1 = x[WB:0];
endmodule
