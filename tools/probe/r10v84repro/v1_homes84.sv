// r10v84 arm v1 — HOMES.  The same read (`localparam int Db = 2` as the BASE
// of the ips closing a hier_path) instantiated from every generate home the
// emitter can put an instance in, plus an interface home and a hier_path that
// walks THROUGH an interface instance.
package pv84;
  parameter int PW = 8;
  parameter int PB = 2;
endpackage

module sinkv84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

interface ifv84;
  typedef struct packed { logic [31:0] q; } fv_t;
  typedef struct packed { fv_t addr;     } rv_t;
  rv_t reg2hw;
  localparam int IDb = 2;
  // (slang refuses `cannot instantiate a module in an interface`, so the
  //  interface home is exercised as the ROOT OF A hier_path instead)
endinterface

module homes84;
  import pv84::*;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int Db = 2;

  sinkv84 #(.W(PW)) h_mod  (.a(reg2hw.addr.q[Db +: PW]));      // module scope

  for (genvar gi = 0; gi < 2; gi++) begin : gf
    sinkv84 #(.W(PW)) h_for (.a(reg2hw.addr.q[Db +: PW]));     // gen-for
  end

  if (1) begin : gi1
    sinkv84 #(.W(PW)) h_if (.a(reg2hw.addr.q[Db +: PW]));      // gen-if
    if (1) begin : gi2
      sinkv84 #(.W(PW)) h_nest (.a(reg2hw.addr.q[Db +: PW]));  // nested gen
    end
  end

  case (Db)
    2: begin : gc
      sinkv84 #(.W(PW)) h_case (.a(reg2hw.addr.q[Db +: PW]));  // gen-case
    end
    default: begin : gcd
      sinkv84 #(.W(PW)) h_cased (.a(reg2hw.addr.q[Db +: PW]));
    end
  endcase

  ifv84 u_if();
  // a hier_path of depth 4 that walks THROUGH an interface instance
  sinkv84 #(.W(PW)) h_ifpath (.a(u_if.reg2hw.addr.q[Db +: PW]));
endmodule

program prgv84;
  logic [7:0] pr8;
  initial pr8 = homes84.reg2hw.addr.q[homes84.Db +: 8];
endprogram
