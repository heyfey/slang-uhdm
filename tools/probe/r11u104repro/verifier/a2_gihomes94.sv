// v11u94 attack arm a2 -- generate / interface homes x net kinds (no logic_net check there)
package a2p;
  localparam longint BLB  = 9223372036854775807;
  localparam longint BADD = 4294967296 + 1;
  localparam int     CLIT = 300;
  localparam int     CPW  = 2 ** 3;
  localparam logic [7:0] LB8 = 8'b10101010;
  localparam bit [7:0] BB8 = 8'b10101010;
  localparam logic [7:0] D8 = 8'd200;
  localparam UD = 8'd200;
endpackage
interface a2ifc;
  wire integer iwBLB = a2p::BLB;
  wire integer iwCLIT = a2p::CLIT;
  wire [3:0] i4BB8 = a2p::BB8;
  wire [3:0] i4UD = a2p::UD;
  wire [3:0] i4D8 = a2p::D8;
  wire [3:0] i4CLIT = a2p::CLIT;
  wire signed [3:0] is4BADD = a2p::BADD;
  wire [1:0][1:0] im4BLB = a2p::BLB;
  wire i1CLIT = a2p::CLIT;
  tri [3:0] it4BLB = a2p::BLB;
endinterface
module a2_gihomes94 (output logic [15:0] o);
  wire integer mwBLB = a2p::BLB;
  wire integer mwCLIT = a2p::CLIT;
  wire integer mwCPW = a2p::CPW;
  wire [3:0] m4BB8 = a2p::BB8;
  wire [3:0] m4UD = a2p::UD;
  wire [3:0] m4D8 = a2p::D8;
  generate if (1) begin : g
    wire integer gwBLB = a2p::BLB;
    wire integer gwCLIT = a2p::CLIT;
    wire integer gwCPW = a2p::CPW;
    wire [3:0] g4BB8 = a2p::BB8;
    wire [3:0] g4LB8 = a2p::LB8;
    wire [3:0] g4UD = a2p::UD;
    wire [3:0] g4D8 = a2p::D8;
    wire signed [3:0] gs4BADD = a2p::BADD;
    wire [1:0][1:0] gm4BLB = a2p::BLB;
    wire g1CLIT = a2p::CLIT;
    tri [3:0] gt4BLB = a2p::BLB;
    wire [127:0] g128BLB = a2p::BLB;
  end endgenerate
  for (genvar k = 0; k < 2; k++) begin : gl
    wire [3:0] l4BLB = a2p::BLB;
    wire [7:0] l8BADD = a2p::BADD;
    wire integer lwCLIT = a2p::CLIT;
  end
  a2ifc ifc ();
  assign o = mwBLB ^ mwCLIT ^ mwCPW ^ m4BB8 ^ m4UD ^ m4D8 ^ g.gwBLB ^ g.gwCLIT ^ g.gwCPW ^ g.g4BB8 ^ g.g4LB8 ^ g.g4UD ^
     g.g4D8 ^ g.gs4BADD ^ g.gm4BLB ^ g.g1CLIT ^ g.gt4BLB ^ g.g128BLB[15:0] ^ gl[0].l4BLB ^ gl[1].l8BADD ^ gl[0].lwCLIT ^
     ifc.iwBLB ^ ifc.iwCLIT ^ ifc.i4BB8 ^ ifc.i4UD ^ ifc.i4D8 ^ ifc.i4CLIT ^ ifc.is4BADD ^ ifc.im4BLB ^ ifc.i1CLIT ^ ifc.it4BLB;
endmodule
