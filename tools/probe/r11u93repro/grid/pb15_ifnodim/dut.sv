// r11u93 pb15 -- non-ANSI interface ports with NO packed dimension.
interface ifc (o, p);
  output o;
  output p;
  wire o = 1'b1;
  wire p = 1'b0;
endinterface
module dut (output logic o);
  logic q;
  ifc u_if (.o(o), .p(q));
endmodule
