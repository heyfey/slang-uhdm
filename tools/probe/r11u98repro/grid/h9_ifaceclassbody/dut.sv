// r11u98 h9 -- CONTROL: a class in an INTERFACE BODY, no generate at all.
interface ifc ();
  wire [31:0] w_plain = 32'd11;
  class C; int x; endclass
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = 32'd0;
endmodule
