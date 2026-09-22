// r11u93 pb6 -- THE CONTROL: the same interface with ANSI ports.
interface ifc (output [31:0] o, output [31:0] p);
  assign o = 32'd12;
  assign p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
