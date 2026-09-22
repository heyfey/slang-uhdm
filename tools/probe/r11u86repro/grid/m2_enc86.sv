// r11u86 arm m2 — THE MODULE-ROUTE ENCODING TABLE.  One MODULE pattern per
// hop home over the same spelling set; the PACKAGE-homed pattern beside it is
// the control that must not move.
package m2p;
  localparam PU  = 5;
  localparam PUN = 'd5;
  localparam PD  = 16'd5;
  localparam PD32= 32'd5;
  localparam PD64= 64'd5;
  localparam PH  = 16'h5;
  localparam PHN = 'h5;
  localparam PO  = 16'o5;
  localparam PB  = 16'b101;
  localparam PN  = -5;
  localparam PND = -16'd5;
  localparam PSD = 16'sd5;
  localparam PSH = 16'sh5;
  localparam PA  = 5 + 1;
  localparam PAD = 16'd9 + 16'd1;
  localparam PCL = $clog2(8);
  localparam int  PTI = 5;
  localparam logic [15:0] PTL = 16'd5;
  localparam PCH = PD;
  typedef struct packed {
    logic [23:0] bail;
    logic [23:0] f0; logic [23:0] f1; logic [23:0] f2; logic [23:0] f3;
    logic [23:0] f4; logic [23:0] f5; logic [23:0] f6; logic [23:0] f7;
    logic [23:0] f8; logic [23:0] f9; logic [23:0] fa; logic [23:0] fb;
    logic [23:0] fc; logic [23:0] fd; logic [23:0] fe; logic [23:0] ff;
    logic [23:0] fg; logic [23:0] fh; logic [23:0] fi;
  } t2;
  localparam t2 PKGCTL = '{bail: 8'hxA,
    f0: PU,  f1: PUN, f2: PD,  f3: PD32, f4: PD64, f5: PH,  f6: PHN,
    f7: PO,  f8: PB,  f9: PN,  fa: PND,  fb: PSD,  fc: PSH, fd: PA,
    fe: PAD, ff: PCL, fg: PTI, fh: PTL,  fi: PCH};
endpackage
module m2_enc86;
  localparam MU  = 5;
  localparam MUN = 'd5;
  localparam MD  = 16'd5;
  localparam MD32= 32'd5;
  localparam MD64= 64'd5;
  localparam MH  = 16'h5;
  localparam MHN = 'h5;
  localparam MO  = 16'o5;
  localparam MB  = 16'b101;
  localparam MN  = -5;
  localparam MND = -16'd5;
  localparam MSD = 16'sd5;
  localparam MSH = 16'sh5;
  localparam MA  = 5 + 1;
  localparam MAD = 16'd9 + 16'd1;
  localparam MCL = $clog2(8);
  localparam int  MTI = 5;
  localparam logic [15:0] MTL = 16'd5;
  localparam MCH = MD;
  localparam m2p::t2 MODPKGHOP = '{bail: 8'hxA,
    f0: m2p::PU,  f1: m2p::PUN, f2: m2p::PD,  f3: m2p::PD32, f4: m2p::PD64,
    f5: m2p::PH,  f6: m2p::PHN, f7: m2p::PO,  f8: m2p::PB,   f9: m2p::PN,
    fa: m2p::PND, fb: m2p::PSD, fc: m2p::PSH, fd: m2p::PA,   fe: m2p::PAD,
    ff: m2p::PCL, fg: m2p::PTI, fh: m2p::PTL, fi: m2p::PCH};
  localparam m2p::t2 MODOWNHOP = '{bail: 8'hxA,
    f0: MU,  f1: MUN, f2: MD,  f3: MD32, f4: MD64, f5: MH,  f6: MHN,
    f7: MO,  f8: MB,  f9: MN,  fa: MND,  fb: MSD,  fc: MSH, fd: MA,
    fe: MAD, ff: MCL, fg: MTI, fh: MTL,  fi: MCH};
endmodule
