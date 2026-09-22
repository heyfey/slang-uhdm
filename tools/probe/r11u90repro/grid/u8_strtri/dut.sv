// r11u90 u8 -- LAW A on a `tri` net, and the CONTROL `supply0` (a net TYPE,
// not a strength) which must keep its net.
interface ifc ();
  tri (pull1, pull0) [31:0] t_str = 32'd1;
  tri [31:0] t_plain = 32'd2;
  supply0 s0;
  supply1 s1;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.t_plain;
endmodule
