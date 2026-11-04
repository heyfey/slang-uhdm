// § rqParamOpBoundAtCall216v (with § ndaRangeQueryFold216) — net initializers querying module and interface parameters with arithmetic bounds, the interface instantiated twice
interface ifx #(parameter int N = 4, parameter logic [N-1:1] IP = 0) ();
  wire [7:0] hq = $high(IP);
  wire [7:0] lq = $low(IP);
endinterface
module dut #(parameter int K = 5, parameter logic [2*K:K+1] MP = 0) (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  wire [7:0] w = $right(MP);
  ifx #(.N(3)) x3 ();
  ifx #(.N(6)) x6 ();
  assign o1 = w;
  assign o2 = x3.hq + x3.lq;
  assign o3 = x6.hq + x6.lq;
endmodule
