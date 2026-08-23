// r10uvm114 arm D — $unit (compilation-unit) typedefs and a program's.
`define WID114 32
parameter int UnitSpan = 12;
typedef bit   [`WID114-1:0]  unitmac_t;
typedef logic [32-1:0]       unitlit_t;
typedef bit   [UnitSpan-1:0] unitspan_t;
typedef bit   [7:0]          unitoct_t;
bit [32-1:0] unitsig;

module gorse114_top;
  unitmac_t  um;
  unitlit_t  ul;
  unitspan_t us;
  initial begin um = 0; ul = 0; us = 0; end
endmodule
