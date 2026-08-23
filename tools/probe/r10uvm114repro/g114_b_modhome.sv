// r10uvm114 arm B — the SAME typedef shapes in a MODULE and in a CLASS.
`define WID114 32

module tallow114_mod;
  parameter  int Span = 12;
  localparam int Half = 6;

  typedef bit   [`WID114-1:0]      cvrmask_t;
  typedef logic [32-1:0]           plainlit_t;
  typedef bit   [7:0]              octet_t;
  typedef logic [Span-1:0]         spanvec_t;
  typedef bit   [0:Span-1]         revspan_t;
  typedef logic [Span+1:2]         offspan_t;
  typedef bit   [Span*2-1:0]       dblspan_t;
  typedef logic [(Span*2)-1:0]     parspan_t;
  typedef bit   [$clog2(Span)-1:0] clogspan_t;
  typedef logic [Half+Span-1:0]    sumspan_t;
  typedef bit   [Span-1:0][3:0]    twodim_t;
  typedef logic [Span-1:0]         unpk_t [4];
  typedef bit   [32-1:0]           unpkrange_t [0:Span-1];
  typedef enum logic [Span-1:0] { TALLOW_A = 0, TALLOW_B = 1 } enumbase_t;
  typedef enum bit [32-1:0] { TALLOW_X = 0 } enumlit_t;
  typedef struct packed { logic [Span-1:0] hi; bit [32-1:0] lo; } packrec_t;

  logic [Span-1:0] modsig;
  bit   [32-1:0]   modlit;
  bit   [`WID114-1:0] modmac;

  class Rasp114;
    typedef bit   [`WID114-1:0] clsmac_t;
    typedef logic [32-1:0]      clslit_t;
    typedef bit   [Span-1:0]    clsspan_t;
    bit [32-1:0] clsfield;
  endclass
endmodule
