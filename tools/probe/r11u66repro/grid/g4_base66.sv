// r11u66 arm g4 — THE FOUR BASES AND THE 'd ABSTENTION (caution (c)).
// pass 49's § pkgSubstEncBasedLitAbstain50v measured golden answering a THIRD
// encoding (DEC:/ct 1) for a based-DECIMAL leaf where `vecBaseCt79` reports
// vpiIntConst.  Does that abstention apply at the ELABORATED pattern-operand
// site?  Each base is carried BARE, through a NAME, and UNDER an arithmetic op.
package q4;
  localparam int DD = 32'd40;
  localparam int HH = 32'h28;
  localparam int BB = 32'b101000;
  localparam int OO = 32'o50;
  localparam int SD = 32'sd40;
  typedef struct packed {
    logic [31:0] bd;   // 32'd40        a BARE based-decimal literal
    logic [31:0] bh;   // 32'h28        a BARE based-hex literal
    logic [31:0] bb;   // 32'b101000    a BARE based-binary literal
    logic [31:0] bo;   // 32'o50        a BARE based-octal literal
    logic [31:0] nd;   // DD            a NAME onto a based-decimal
    logic [31:0] nh;   // HH            a NAME onto a based-hex
    logic [31:0] nb;   // BB            a NAME onto a based-binary
    logic [31:0] no;   // OO            a NAME onto a based-octal
    logic [31:0] ad;   // 32'd40 - 8    a based-decimal UNDER a subtract
    logic [31:0] ah;   // 32'h28 - 8    a based-hex UNDER a subtract
    logic [31:0] ab;   // 32'b101000 - 8
    logic [31:0] ao;   // 32'o50 - 8
    logic [31:0] pd;   // DD + 2        a NAME to 'd UNDER an add
    logic [31:0] ph;   // HH + 2        a NAME to 'h UNDER an add
    logic [31:0] sd;   // 32'sd40 - 8   the SIGNED 'd form
    logic [31:0] ns;   // SD            a NAME onto the signed 'd form
    logic [31:0] ul;   // 40            a plain unsized literal (control)
    logic [31:0] uv;   // 40 - 8        a plain unsized subtract (control)
  } c4_t;
  localparam c4_t L4 = '{bd: 32'd40, bh: 32'h28, bb: 32'b101000, bo: 32'o50,
                         nd: DD, nh: HH, nb: BB, no: OO,
                         ad: 32'd40 - 8, ah: 32'h28 - 8, ab: 32'b101000 - 8,
                         ao: 32'o50 - 8, pd: DD + 2, ph: HH + 2,
                         sd: 32'sd40 - 8, ns: SD, ul: 40, uv: 40 - 8};
endpackage
module g4_base66 #(parameter q4::c4_t C = q4::L4)
                 (output logic [31:0] o01, output logic [31:0] o02,
                  output logic [31:0] o03, output logic [31:0] o04,
                  output logic [31:0] o05, output logic [31:0] o06,
                  output logic [31:0] o07, output logic [31:0] o08,
                  output logic [31:0] o09, output logic [31:0] o10,
                  output logic [31:0] o11, output logic [31:0] o12,
                  output logic [31:0] o13, output logic [31:0] o14,
                  output logic [31:0] o15, output logic [31:0] o16,
                  output logic [31:0] o17, output logic [31:0] o18);
  assign o01 = C.bd; assign o02 = C.bh; assign o03 = C.bb; assign o04 = C.bo;
  assign o05 = C.nd; assign o06 = C.nh; assign o07 = C.nb; assign o08 = C.no;
  assign o09 = C.ad; assign o10 = C.ah; assign o11 = C.ab; assign o12 = C.ao;
  assign o13 = C.pd; assign o14 = C.ph; assign o15 = C.sd; assign o16 = C.ns;
  assign o17 = C.ul; assign o18 = C.uv;
endmodule
