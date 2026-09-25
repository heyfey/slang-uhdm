// § modArrayBoundRefArrayPath146
interface myif; logic v; endinterface
module dut #(parameter int N=2)(output logic o);
  myif m[N-1:0]();
  assign o = m[0].v;
endmodule
