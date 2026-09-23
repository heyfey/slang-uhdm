// v11u94 attack arm a3 -- the seven flags now ON in non-nda homes, narrow targets, every arm
package a3p;
  localparam longint BLB  = 9223372036854775807;
  localparam longint BADD = 4294967296 + 1;
  localparam longint BOR  = 4294967296 | 255;
  localparam longint BAND = 12884901888 & 8589934847;
  localparam longint BSHL = 2147483648 << 1;
  localparam longint BSHR = 8589934592 >> 1;
  localparam int     IB31 = 2147483648;
  localparam int     CNAM = BLB;
  localparam int     IADD = 2147483647 + 1;
  localparam byte    YADD = 100 + 100;
  localparam logic [7:0] LOR = 8'hF0 | 8'h0F;
  localparam shortint SSHL = 1 << 15;
endpackage
module a3sub #(parameter logic [7:0] P8 = 0) (input logic [7:0] i8, output logic [7:0] q);
  assign q = P8 ^ i8;
endmodule
module a3_nonnda94 (input logic clk, input logic [63:0] a, output logic [63:0] o);
  logic [7:0] vBLB = a3p::BLB;
  logic [7:0] vBADD = a3p::BADD;
  logic [63:0] vBSHL = a3p::BSHL;
  logic [7:0] vIADD = a3p::IADD;
  logic [7:0] vYADD = a3p::YADD;
  wire [7:0] aIADD, aYADD, aLOR, aSSHL, aIB31, aCNAM;
  assign aIADD = a3p::IADD;
  assign aYADD = a3p::YADD;
  assign aLOR = a3p::LOR;
  assign aSSHL = a3p::SSHL;
  assign aIB31 = a3p::IB31;
  assign aCNAM = a3p::CNAM;
  logic [7:0] pBOR, pBAND, pBSHR, pIADD, pYADD, pSSHL, fq;
  always_ff @(posedge clk) begin
    pBOR <= a3p::BOR;
    pBAND <= a3p::BAND;
    pBSHR <= a3p::BSHR;
    pIADD <= a3p::IADD;
    pYADD <= a3p::YADD;
    pSSHL <= a3p::SSHL;
  end
  logic [7:0] cq;
  always_comb begin
    case (a[7:0])
      a3p::YADD: cq = 1;
      a3p::LOR: cq = 2;
      default: cq = a3p::IADD;
    endcase
  end
  wire [7:0] q1, q2, q3;
  a3sub #(.P8(a3p::BADD)) u1 (.i8(a3p::YADD), .q(q1));
  a3sub #(.P8(a3p::IADD)) u2 (.i8(a3p::BSHL), .q(q2));
  a3sub #(.P8(a3p::LOR)) u3 (.i8(a3p::IB31), .q(q3));
  function automatic logic [7:0] fYADD(); return a3p::YADD; endfunction
  function automatic logic [15:0] fSSHL(); return a3p::SSHL; endfunction
  wire [7:0] xIADD = a3p::IADD ^ 8'h1;
  wire [7:0] xYADD = {a3p::YADD};
  wire [7:0] xpar = (a3p::YADD);
  wire [7:0] xcast = 8'(a3p::BADD);
  localparam logic [7:0] LPY = a3p::YADD;
  localparam logic [3:0] LP4 = a3p::BOR;
  wire [7:0] wLPY = LPY;
  wire [3:0] wLP4 = LP4;
  assign o = vBLB ^ vBADD ^ vBSHL ^ vIADD ^ vYADD ^ aIADD ^ aYADD ^ aLOR ^ aSSHL ^ aIB31 ^ aCNAM ^ pBOR ^ pBAND ^ pBSHR ^
    pIADD ^ pYADD ^ pSSHL ^ cq ^ q1 ^ q2 ^ q3 ^ fYADD() ^ fSSHL() ^ xIADD ^ xYADD ^ xpar ^ xcast ^ wLPY ^ wLP4;
endmodule
