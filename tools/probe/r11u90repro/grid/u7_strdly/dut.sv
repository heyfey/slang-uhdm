// r11u90 u7 -- LAW A: a strength AND a delay on the net declaration
// (LRM order: net_type [drive_strength] data_type [delay3] assignments).
interface ifc ();
  wire (strong1, weak0) [31:0] #3 w_sd = 32'd12;
  wire [31:0] #3 w_d = 32'd13;
  wire [31:0] w_p = 32'd14;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_p ^ u_if.w_d;
endmodule
