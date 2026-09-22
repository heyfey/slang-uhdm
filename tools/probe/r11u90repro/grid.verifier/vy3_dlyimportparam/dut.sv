// v11u90 vy3 -- the delay name arrives by EXPLICIT package import.
package pk;
  parameter int PD = 6;
endpackage
module sub (output logic [31:0] o);
  import pk::PD;
  logic [31:0] c;
  assign #PD c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
