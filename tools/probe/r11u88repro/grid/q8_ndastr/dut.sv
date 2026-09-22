// r11u88 q8 -- THE DECLINE, measured not copied: a net declaration carrying a
// DRIVE STRENGTH.  Golden writes neither the net nor a cont_assign for it.
// Measurement-only arm for this pass; recorded as a residue.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  wire (supply0, supply1) [31:0] w_str2 = 32'd13;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_plain;
endmodule
