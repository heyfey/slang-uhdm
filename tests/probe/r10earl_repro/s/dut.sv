// r10earl3 s.sv — UNINSTANTIATED-DEFINITION EMISSION, ported module.
// `sInnerPorted` is instantiated ONLY inside the untaken arm of a generate
// if.  Surelog compiles every parsed module, so it must carry a DEF view in
// design->AllModules; we currently drop it because addDefOnlyModule admits a
// non-taken-branch def only when it is PORTLESS.
module sInnerPorted (input logic a, output logic b);
  assign b = ~a;
endmodule

module sInnerPortless;
  logic z;
  assign z = 1'b0;
endmodule

module sTop #(parameter int SEL = 0) (input logic x, output logic y);
  if (SEL == 1) begin : g_taken
    sInnerPorted u(.a(x), .b(y));
    sInnerPortless v();
  end
  else begin : g_else
    assign y = x;
  end
endmodule
