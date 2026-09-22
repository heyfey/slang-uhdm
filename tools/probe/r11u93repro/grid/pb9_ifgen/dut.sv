// r11u93 pb9 -- a GENERATE block beside non-ANSI interface ports.
interface ifc (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
  generate
    if (1) begin : g
      wire [31:0] w_gen = 32'd14;
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
