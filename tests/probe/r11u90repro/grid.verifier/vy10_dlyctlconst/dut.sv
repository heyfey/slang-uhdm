// v11u90 vy10 -- CONTROL: plain numeric delays, interface and module homes.
interface ifc ();
  logic [31:0] c;
  assign #7 c = 32'd10;
endinterface
module sub (output logic [31:0] o);
  logic [31:0] c;
  assign #2.5 c = 32'd11;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if ();
  sub u_s (.o(q));
  assign o = q ^ u_if.c;
endmodule
