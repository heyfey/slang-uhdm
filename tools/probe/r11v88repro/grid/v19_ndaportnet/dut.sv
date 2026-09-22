// v11u88 v19 -- an interface HEADER PORT net beside a net-decl-assign, and the
// interface passed by reference to a child (the PORT VIEW).
interface ifc (input logic clk);
  wire [31:0] w_nd = 32'd11;
  logic [31:0] c;
  assign c = 32'd12;
endinterface

module sub (ifc s, output logic [31:0] y);
  assign y = s.w_nd ^ s.c;
endmodule

module dut (input logic clk, output logic [31:0] o);
  ifc u_if (.clk(clk));
  sub u_s (.s(u_if), .y(o));
endmodule
