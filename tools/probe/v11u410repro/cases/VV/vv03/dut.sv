// § modVirtIfaceTd410
interface I #(parameter W = 2); logic [W-1:0] a; endinterface
module top;
  typedef virtual I #(4) vi_t;
  vi_t h;
  I #(4) u();
endmodule
