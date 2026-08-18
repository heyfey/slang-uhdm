// v8 — THE FENCE: based-literal indices with NO genvar (compileConst keeps the
// literal's own spelling and size) next to genvar-dependent ones.
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v;
endmodule
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module top (input logic [63:0] arr);
  sif sarr [0:63] ();
  genvar i;
  ileaf t0 (.s (sarr[5'd10]));
  ileaf t1 (.s (sarr[1'b0]));
  ileaf t2 (.s (sarr[6'h0a]));
  ileaf t3 (.s (sarr[4]));
  nleaf t4 (.p (arr[5'd10]));
  nleaf t5 (.p (arr[1'b0]));
  for (i = 0; i < 2; ++i) begin : g
    ileaf u0 (.s (sarr[5'd10]));
    ileaf u1 (.s (sarr[1'b0]));
    ileaf u2 (.s (sarr[6'h0a]));
    ileaf u3 (.s (sarr[4]));
    ileaf u4 (.s (sarr[5'd10+i]));
    nleaf u5 (.p (arr[5'd10]));
    nleaf u6 (.p (arr[1'b0]));
    nleaf u7 (.p (arr[5'd10+i]));
    nleaf u8 (.p (arr[4]));
  end
endmodule
