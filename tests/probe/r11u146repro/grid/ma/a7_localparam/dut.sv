// § modArrayBoundRefArrayPath146
interface myif; logic v; endinterface
module dut(output logic o);
  localparam int N = 3;
  myif m[N-1:0]();
  assign o = m[0].v;
endmodule
