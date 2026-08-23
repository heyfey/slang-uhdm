// r10v76 arm a3 -- THE IMPORT-SITE GRID.  § genScopeProcLoopCtrlNoFold76 is
// decoded from "a generate block is its OWN DesignComponent and its
// param_assigns hold only its own localparams".  If the IMPORT itself sits on
// the generate block (or in the process's own block), Surelog's
// component-level getParam_assigns() arm could materialize the package
// parameter INTO the generate block and GOLDEN WOULD FOLD -- which the law as
// written cannot see.  This arm is the attack.
package v76p3;
  parameter int NB = 4;
  parameter int NC = 6;
endpackage
package v76q3;
  parameter int QB = 11;
endpackage

module v76imp #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  logic [31:0] c1, c2, c3, c4, c5;

  // A: the import is on the GENERATE BLOCK itself
  if (P > 0) begin : gi_a
    import v76p3::*;
    always_comb begin
      c1 = '0;
      for (int i = 0; i < NB; i++) c1 = c1 + 1;
      repeat (NC) c1 = c1 + 1;
    end
  end

  // B: the import is inside the PROCESS's own begin block
  if (P > 0) begin : gi_b
    always_comb begin
      import v76p3::*;
      c2 = '0;
      for (int i = 0; i < NB; i++) c2 = c2 + 1;
    end
  end

  // C: the import is on the MODULE (the law's own home) -- the control
  if (P > 0) begin : gi_c
    always_comb begin
      c3 = '0;
      for (int i = 0; i < v76p3::NB; i++) c3 = c3 + 1;   // QUALIFIED control
    end
  end

  // D: an EXPLICIT single import on the generate block
  if (P > 0) begin : gi_d
    import v76q3::QB;
    always_comb begin
      c4 = '0;
      for (int i = 0; i < QB; i++) c4 = c4 + 1;
    end
  end

  // E: the import is on the MODULE and the read is inside a NESTED gen block
  //    whose own scope has no import at all
  if (P > 0) begin : gi_e
    if (P > 1) begin : gi_ee
      always_comb begin
        c5 = '0;
        for (int i = 0; i < v76p3::NC; i++) c5 = c5 + 1;
      end
    end
  end

  assign o = c1 ^ c2 ^ c3 ^ c4 ^ c5;
endmodule

// The compilation-unit import: no module-level import at all.
import v76p3::*;
module v76cu #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  logic [31:0] d1, d2;
  always_comb begin                     // MODULE-BODY twin, $unit import only
    d1 = '0;
    for (int i = 0; i < NB; i++) d1 = d1 + 1;
  end
  if (P > 0) begin : gu_a
    always_comb begin
      d2 = '0;
      for (int i = 0; i < NB; i++) d2 = d2 + 1;
      repeat (NC) d2 = d2 + 1;
    end
  end
  assign o = d1 ^ d2;
endmodule

module v76imptop (input logic clk, output logic [31:0] o1, output logic [31:0] o2);
  v76imp #(2) u_i (.clk(clk), .o(o1));
  v76cu  #(2) u_c (.clk(clk), .o(o2));
endmodule
