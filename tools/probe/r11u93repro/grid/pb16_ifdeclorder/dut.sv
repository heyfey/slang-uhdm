// r11u93 pb16 -- the HEADER order and the PORT-DECLARATION order DISAGREE.
interface ifc (p, o);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
