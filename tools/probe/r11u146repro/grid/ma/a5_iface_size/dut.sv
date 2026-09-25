// § modArrayBoundRefArrayPath146
interface myif; logic v; endinterface
module dut #(parameter int N=2)(output logic o);
  myif m[N]();
  assign o = m[0].v;
endmodule
