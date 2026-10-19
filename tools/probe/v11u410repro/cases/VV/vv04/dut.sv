// § modVirtIfaceTd410
interface I; logic a; endinterface
typedef virtual I vi_t;
module top;
  vi_t h [2];
endmodule
