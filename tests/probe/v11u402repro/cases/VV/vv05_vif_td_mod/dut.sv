// § virtIfaceTd402
interface I; logic a; endinterface
module top;
  typedef virtual I vi_t;
  vi_t v;
endmodule
