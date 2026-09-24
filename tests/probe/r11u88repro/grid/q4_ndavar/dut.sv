// r11u88 q4 -- THE FENCE: a VARIABLE initializer in an interface is NOT a
// net-decl-assign (`elabSignal`'s net branch alone mints the cell; the var
// branch hands the expression to `makeVar_`).
interface ifc ();
  logic [31:0] v_init = 32'd21;
  wire  [31:0] w_init = 32'd22;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.v_init ^ u_if.w_init;
endmodule
