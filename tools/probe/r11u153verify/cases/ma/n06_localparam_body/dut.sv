// § modArrayBoundRefArrayPath146
interface ifc; logic x; endinterface
module dut(output logic o);
  localparam int K = 3;
  ifc i[K-1:0]();
  assign o = i[0].x;
endmodule
