// r11u88 q3 -- LAW A x the net declaration's own DELAY (`wire #3 w = ...`),
// which `NetlistElaboration::elabSignal` compiles onto the net-decl-assign.
interface ifc ();
  wire [31:0] w_d  = 32'd11;
  wire [31:0] #3 w_dd = 32'd12;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_d ^ u_if.w_dd;
endmodule
