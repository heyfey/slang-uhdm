// r10v84 arm v5 — THE BIND REGRESSION, MINIMISED.
// Surelog KEEPS the `ref_obj` at the ips BASE of a hier_path inside the
// ELABORATED port High_conn of a `bind` instantiation.  Pristine keeps it too
// (they AGREE); the r10earl84 law as submitted folds it — RIGHT->WRONG.
module bnd84 (input logic [7:0] a);
endmodule

module bindee84;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int Bd = 2;
endmodule

module top5_84;
  bindee84 u_be ();
endmodule

bind bindee84 bnd84 u_bind (.a(reg2hw.addr.q[Bd +: 8]));
