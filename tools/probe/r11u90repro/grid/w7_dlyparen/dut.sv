// r11u90 w7 -- LAW B: the PARENTHESISED one-value delay `#(D)`.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c;
  assign #(D) c = 32'd10;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.c;
endmodule
