// r10v76 arm a6 -- the IMPORT-SITE corners a3 does not separate: the module
// AND the generate block both import; the module imports one package and the
// gen block another; and an EXPLICIT module-level single import.
package v76p6;
  parameter int NB = 4;
endpackage
package v76q6;
  parameter int QB = 11;
endpackage

// X: the MODULE imports and the GEN BLOCK imports the SAME package
module v76x (output logic [31:0] o);
  import v76p6::*;
  logic [31:0] x1;
  if (1) begin : gx_a
    import v76p6::*;
    always_comb begin
      x1 = '0;
      for (int i = 0; i < NB; i++) x1 = x1 + 1;
    end
  end
  assign o = x1;
endmodule

// Y: the MODULE imports p6, the GEN BLOCK imports q6; both are read
module v76y (output logic [31:0] o);
  import v76p6::*;
  logic [31:0] y1;
  if (1) begin : gy_a
    import v76q6::*;
    always_comb begin
      y1 = '0;
      for (int i = 0; i < NB; i++) y1 = y1 + 1;   // MODULE-imported
      for (int i = 0; i < QB; i++) y1 = y1 + 1;   // GEN-BLOCK-imported
    end
  end
  assign o = y1;
endmodule

// Z: an EXPLICIT single import on the MODULE
module v76z (output logic [31:0] o);
  import v76p6::NB;
  logic [31:0] z1;
  if (1) begin : gz_a
    always_comb begin
      z1 = '0;
      for (int i = 0; i < NB; i++) z1 = z1 + 1;
    end
  end
  assign o = z1;
endmodule

module v76xtop (output logic [31:0] o1, output logic [31:0] o2, output logic [31:0] o3);
  v76x u_x (.o(o1));
  v76y u_y (.o(o2));
  v76z u_z (.o(o3));
endmodule
