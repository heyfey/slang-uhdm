// a3: the same untyped unsized-hex parameter in every home
parameter H_UNIT = 'h11;
package a3_pkg;
  parameter H_PKG = 'h22;
endpackage
interface a3_if;
  parameter H_IF = 'h33;
endinterface
program a3_pgm;
  parameter H_PGM = 'h44;
  initial $display(H_PGM);
endprogram
module a3_body;
  parameter H_HDRLESS = 'h55;
  localparam H_LOC = 'h66;
  if (1) begin : g
    localparam H_GEN = 'h77;
    initial $display(H_GEN);
  end
  for (genvar i = 0; i < 2; i++) begin : gf
    localparam H_GENF = 'h88;
    initial $display(H_GENF);
  end
  function automatic int f();
    localparam H_FUNC = 'h99;
    return H_FUNC;
  endfunction
  initial $display(H_HDRLESS, H_LOC, f(), H_UNIT);
endmodule
module a3_hdr #(parameter H_HDR = 'haa) ();
  initial $display(H_HDR);
endmodule
class a3_cls;
  parameter H_CLS = 'hbb;
  localparam H_CLOC = 'hcc;
  function int g(); return H_CLS + H_CLOC; endfunction
endclass
module a3_top;
  a3_body b1();
  a3_hdr  h1();
  a3_if   i1();
  a3_pgm  p1();
  a3_cls  c1;
  import a3_pkg::*;
  initial $display(H_PKG);
endmodule
