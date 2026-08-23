// r10uvm114 arm A — packed/unpacked dimension bounds in a PACKAGE's typedefs.
`define WID114 32
`define NARROW114 8

package quill114_pkg;
  parameter  int Span = 12;
  localparam int Half = 6;

  typedef bit   [`WID114-1:0]      cvrmask_t;              // macro literal - 1
  typedef logic [32-1:0]           plainlit_t;             // written literal op
  typedef bit   [7:0]              octet_t;                // literal control
  typedef logic [Span-1:0]         spanvec_t;              // param - 1
  typedef bit   [0:Span-1]         revspan_t;              // reversed
  typedef logic [Span+1:2]         offspan_t;              // plus, nonzero right
  typedef bit   [Span*2-1:0]       dblspan_t;              // mult then minus
  typedef logic [(Span*2)-1:0]     parspan_t;              // parenthesized left
  typedef bit   [$clog2(Span)-1:0] clogspan_t;             // sys call - 1
  typedef logic [Half+Span-1:0]    sumspan_t;              // three-term
  typedef bit   [`NARROW114*2-1:0] macmul_t;               // macro * 2 - 1
  typedef bit   [Span-1:0][3:0]    twodim_t;               // two packed dims
  typedef logic [Span-1:0]         unpk_t [4];             // packed + unpacked
  typedef bit   [32-1:0]           unpkrange_t [0:Span-1]; // unpacked range dim
  typedef enum logic [Span-1:0] { QUILL_A = 0, QUILL_B = 1 } enumbase_t;
  typedef enum bit [32-1:0] { LEDGER_X = 0 } enumlit_t;
  typedef struct packed { logic [Span-1:0] hi; bit [32-1:0] lo; } packrec_t;
  typedef struct { logic [Span-1:0] wide; bit [16-1:0] slim; } looserec_t;

  typedef bit [Span-1:0] twinleft_t; typedef bit [32-1:0] twinright_t;

  logic [Span-1:0] pkgsig;
  bit   [32-1:0]   pkglit;
  bit   [`WID114-1:0] pkgmac;
endpackage
