// § modVirtIfaceTd410
interface I(input logic clk); logic a; modport mp(input a); endinterface
module top;
  typedef virtual I.mp vm_t;
  typedef virtual interface I vi_t;
  vm_t v;
  vi_t w;
endmodule
