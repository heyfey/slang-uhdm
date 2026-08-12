// r10svs6 arm b5 — the VIRTUAL-INTERFACE element in every written spelling, plus
// the class-handle element in the shapes § typeParamRetIsRefVar58 touches.
// § virtualIfacePropIsBareLogicVar6 established that a SCALAR virtual-interface
// property is a BARE logic_var with NO typespec at all; this arm asks what the
// ELEMENT of a fixed array of them is, for all four spellings and through a
// typedef, and whether the element of a fixed array of TYPE-PARAMETER handles
// resolves (the class-property `Parameter` branch) or degrades.
interface w_if;
  logic clk;
  logic d;
  clocking cb @(posedge clk);
    output d;
  endclocking
  modport IP(clocking cb, input clk);
endinterface

typedef virtual w_if.IP wif_t;

class H5;
  int id;
endclass

class b5_cls;
  virtual w_if.IP c01_vifmp[4];
  virtual w_if c02_vifbare[4];
  virtual interface w_if c03_vifkw[4];
  virtual interface w_if.IP c04_vifkwmp[4];
  wif_t c05_viftd[4];
  virtual w_if.IP c06_vif2d[4][2];
  H5 c07_hnd[4];
  H5 c08_hnd2d[4][2];
endclass

class b5_par #(type T = H5);
  T c09_tphnd[4];
endclass

module b5_top;
  b5_cls c;
  b5_par #(H5) p;
endmodule
