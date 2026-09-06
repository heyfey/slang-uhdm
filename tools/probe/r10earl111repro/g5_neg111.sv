// r10earl111 arm g5 -- THE NEGATIVE CONTROLS.  Every cell here is one this law
// must LEAVE ALONE, and each is a shape that a wider reading of the head would
// have broken.
//   c1  THE `vaddr_width_p` SHAPE -- an IMPLICITLY typed module localparam
//       whose RHS is a struct-member read, so Surelog's parameter carries NO
//       typespec and the folded width is BARE in golden.  This is the cell the
//       refuted declaration comment was written from; the law refuses it on
//       the IMPLICIT test, and this arm is the proof that refusing is right.
//   c2  the same shape with an EXPLICIT `int unsigned` -- admitted, so the arm
//       shows the axis is the declared type and not the struct-member RHS.
//   c3  an OVERRIDABLE module `parameter int` -- § hierSelWidthOvParamNoFold:
//       it must not fold AT ALL, so there is no constant to stamp.
//   c4  an ELABORATED PORT High_conn width from a module `int` localparam --
//       § connIpsPkgParamBoundNoTs65's carve-out, which this law rides inside.
//   c5  THE flash_phy.sv:128/133 SHAPE -- a PACKAGE `parameter int` read as
//       the width inside an elaborated port High_conn.  Golden is BARE there
//       and so is the pristine emitter (the same carve-out); this arm proves
//       the widened gate did not reopen it.
//   c6  THE prim_ram_2p_async_adv.sv:178/185 SHAPE -- an OVERRIDABLE module
//       `parameter int` read as the width of a PLAIN (undotted) net select.
//       Golden folds the value and leaves it BARE; the fold does not go
//       through either site this law owns, and `selWidthParamFold` refuses an
//       overridable parameter anyway (§ hierSelWidthOvParamNoFold).
//   c7  THE generate_test/dut.sv:52 SHAPE -- an IMPLICIT overridable module
//       parameter as a plain-select width inside a port High_conn.
package pk5111;
  typedef struct packed { logic [15:0] vw; logic [15:0] dw; } cfg_t;
  typedef struct packed { logic [31:0] src; logic v; } h_t;
  localparam cfg_t CFG = '{vw: 16'd2, dw: 16'd2};
  parameter  int   PKW = 2;                  // c5's package `parameter int`
endpackage

module sink5111 (input logic [1:0] a_i, output logic [1:0] b_o);
  assign b_o = a_i;
endmodule

module s5111 #(parameter int OVW = 2, parameter DW = 2)
              (input pk5111::h_t h_i, output logic [63:0] o);
  localparam       C1 = pk5111::CFG.vw;      // IMPLICIT, struct-member RHS
  localparam int unsigned C2 = pk5111::CFG.dw;  // EXPLICIT, same RHS
  localparam int unsigned C4 = 2;
  logic [63:0] r;
  logic [1:0]  hc, hc5, hc7;
  logic [31:0] flat;
  for (genvar gi = 0; gi < 1; gi++) begin : gb
    assign r[ 1: 0] = h_i.src[0 +: C1];      // c1 must stay BARE
    assign r[ 3: 2] = h_i.src[0 +: C2];      // c2 admitted
    assign r[ 5: 4] = h_i.src[0 +: OVW];     // c3 must not fold at all
    sink5111 u_hc (.a_i(h_i.src[0 +: C4]), .b_o(hc));     // c4 High_conn
    sink5111 u_p5 (.a_i(h_i.src[0 +: pk5111::PKW]), .b_o(hc5)); // c5
    assign r[ 9: 8] = flat[0 +: OVW];                     // c6 plain select
    sink5111 u_p7 (.a_i(flat[0 +: DW]), .b_o(hc7));       // c7
  end
  assign r[ 7: 6] = hc;
  assign r[11:10] = hc5;
  assign r[13:12] = hc7;
  assign flat = 32'd0;
  assign o = r;
endmodule

module g5_neg111;
  pk5111::h_t s;
  logic [63:0] oo;
  s5111 #(.OVW(2), .DW(2)) u (.h_i(s), .o(oo));
endmodule
