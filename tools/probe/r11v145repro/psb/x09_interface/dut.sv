// § psBoundBareRefByBase145
interface ifc;
  localparam int H = 5;
  localparam int L = 1;
  logic [7:0] d;
  logic [4:0] q;
  assign q = d[H:L];
endinterface
module dut(output logic [4:0] o);
  ifc u();
  assign u.d = 8'h5a;
  assign o = u.q;
endmodule
