// v11u94 attack arm a6 -- parameterized reader widths, typed params (enum/struct), implicit-range signed literals
package a6p;
  typedef enum logic [7:0] {EA = 200, EB = 7} e_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  localparam longint BLB = 9223372036854775807;
  localparam longint BADD = 4294967296 + 1;
  localparam int CLIT = 300;
  localparam e_t EP = EA;
  localparam s_t SP = '{hi: 4'hA, lo: 4'h5};
  localparam s_t SP2 = 8'hC3;
  localparam [7:0] IRS = 8'sb10101010;
  localparam signed [7:0] ISS = 8'sb10101010;
  localparam signed IS1 = 8'sb10101010;
  localparam [7:0] IRP = 8'sb00001010;
  localparam logic [7:0] LOR = 8'hF0 | 8'h0F;
  localparam logic [15:0] LSHL = 16'h00FF << 4;
endpackage
module a6sub #(parameter int W = 8) (output logic [15:0] q);
  wire [W-1:0] pBLB = a6p::BLB;
  wire [W-1:0] pCLIT = a6p::CLIT;
  wire [W-1:0] pBADD = a6p::BADD;
  wire [W-1:0] pLOR = a6p::LOR;
  assign q = pBLB ^ pCLIT ^ pBADD ^ pLOR;
endmodule
module a6_paramw94 (output logic [15:0] o);
  wire [3:0] eEP4 = a6p::EP;
  wire [15:0] eEP16 = a6p::EP;
  wire [3:0] sSP4 = a6p::SP;
  wire [15:0] sSP16 = a6p::SP;
  wire [3:0] sSP24 = a6p::SP2;
  wire [3:0] iIRS4 = a6p::IRS;
  wire [15:0] iIRS16 = a6p::IRS;
  wire [3:0] iISS4 = a6p::ISS;
  wire [15:0] iISS16 = a6p::ISS;
  wire [3:0] iIS14 = a6p::IS1;
  wire [3:0] iIRP4 = a6p::IRP;
  wire [3:0] lLOR4 = a6p::LOR;
  wire [7:0] lLSHL8 = a6p::LSHL;
  wire [15:0] q1, q2, q3;
  a6sub #(.W(4)) u4 (.q(q1));
  a6sub #(.W(16)) u16 (.q(q2));
  a6sub u8 (.q(q3));
  assign o = q1 ^ q2 ^ q3 ^ eEP4 ^ eEP16 ^ sSP4 ^ sSP16 ^ sSP24 ^ iIRS4 ^ iIRS16 ^ iISS4 ^ iISS16 ^ iIS14 ^ iIRP4 ^ lLOR4 ^ lLSHL8;
endmodule
