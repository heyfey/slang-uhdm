// § ifArrElemLitCaFresh225 — a bound module naming the array
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module chk(output logic q);
  localparam int K = 0;
  bi c[2]();
  assign c[K].w = 1'b1;
  assign q = c[0].w;
endmodule
module dut(output logic o);
  assign o = 1'b0;
endmodule
bind dut chk u_chk(.q());
