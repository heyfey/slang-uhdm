// v11u94 attack arm a8 -- the signed-binary fix's controls: untyped leaves under typed hops, program /
// nested-module / parameterized-interface homes
package a8p;
  localparam IS8N = 8'sb10101010;
  localparam IS8P = 8'sb00101010;
  localparam logic [7:0] HN = IS8N;
  localparam HU = IS8N;
  localparam signed [7:0] HS = IS8N;
  localparam logic [7:0] HP = IS8P;
  localparam longint BLB = 9223372036854775807;
  localparam int CLIT = 300;
  localparam logic signed [7:0] SA = 8'sb10101010;
endpackage
interface a8ifc #(parameter int W = 4);
  wire [W-1:0] iBLB = a8p::BLB;
  wire [W-1:0] iCLIT = a8p::CLIT;
  wire [W-1:0] iSA = a8p::SA;
endinterface
program a8prog (output logic [7:0] po);
  wire [3:0] prBLB = a8p::BLB;
  wire [3:0] prSA = a8p::SA;
  assign po = {prBLB, prSA};
endprogram
module a8_fixctl94 (output logic [15:0] o);
  module a8nest (output logic [7:0] no);
    wire [3:0] nBLB = a8p::BLB;
    wire [3:0] nSA = a8p::SA;
    assign no = {nBLB, nSA};
  endmodule
  wire [3:0] hHN4 = a8p::HN;
  wire [15:0] hHN16 = a8p::HN;
  wire [3:0] hHU4 = a8p::HU;
  wire [3:0] hHS4 = a8p::HS;
  wire [3:0] hHP4 = a8p::HP;
  wire [3:0] hIS8N4 = a8p::IS8N;
  wire [3:0] hIS8P4 = a8p::IS8P;
  wire [7:0] po, no;
  a8prog pr (.po(po));
  a8nest ne (.no(no));
  a8ifc #(.W(2)) i2 ();
  a8ifc #(.W(16)) i16 ();
  assign o = hHN4 ^ hHN16 ^ hHU4 ^ hHS4 ^ hHP4 ^ hIS8N4 ^ hIS8P4 ^ po ^ no ^ i2.iBLB ^ i2.iCLIT ^ i2.iSA ^ i16.iBLB ^ i16.iCLIT ^ i16.iSA;
endmodule
