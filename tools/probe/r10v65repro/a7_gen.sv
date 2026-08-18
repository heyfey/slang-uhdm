// v65 ARM 7 — the EXACT SHAPE OF THE EARLGREY HEAD: a DOTTED (hier_path) ips
// bound folding a PACKAGE localparam inside an ELABORATED port High_conn that
// lives in a GEN-FOR / GEN-IF / nested gen scope, plus an interface-borne
// version and a struct port.  MEASUREMENT ONLY.
package pa7;
  localparam int PageW = 8;
  localparam int WordW = 8;
  localparam int BankAddrW = PageW + WordW;   // 16, computed like flash_ctrl_pkg
  localparam int BankW = 1;
endpackage

typedef struct packed { logic [63:0] addr; logic [63:0] data; } req7_t;

interface if7;
  req7_t r;
  modport mp (input r);
endinterface

module leaf7 (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

module mid7 import pa7::*; (input req7_t q_i, output logic [3:0] o_o);
  for (genvar b = 0; b < 2; b++) begin : gen_banks
    leaf7 i_core (.a_i({16'b0, q_i.addr[0 +: BankAddrW]}), .b_i(q_i.data[0]),
                  .o_o(o_o[b]));
  end
  if (BankW == 1) begin : gen_one
    leaf7 i_one (.a_i({16'b0, q_i.addr[0 +: BankAddrW]}), .b_i(q_i.data[0]),
                 .o_o(o_o[2]));
  end
  leaf7 i_plain (.a_i({16'b0, q_i.addr[0 +: BankAddrW]}), .b_i(q_i.data[0]),
                 .o_o(o_o[3]));
endmodule

module ifuse7 import pa7::*; (if7.mp p, output logic o_o);
  leaf7 i_if (.a_i({16'b0, p.r.addr[0 +: BankAddrW]}), .b_i(p.r.data[0]),
              .o_o(o_o));
endmodule

module a7_gen import pa7::*; (input req7_t q_i, output logic [7:0] o_o);
  mid7 u_mid (.q_i(q_i), .o_o(o_o[3:0]));
  // three instances of the identical dotted shape at module scope
  leaf7 u_a (.a_i({16'b0, q_i.addr[0 +: BankAddrW]}), .b_i(q_i.data[0]), .o_o(o_o[4]));
  leaf7 u_b (.a_i({16'b0, q_i.addr[0 +: BankAddrW]}), .b_i(q_i.data[0]), .o_o(o_o[5]));
  leaf7 u_c (.a_i({16'b0, q_i.addr[WordW +: 16]}),    .b_i(q_i.data[0]), .o_o(o_o[6]));
  if7 the_if ();
  assign the_if.r = q_i;
  ifuse7 u_if (.p(the_if.mp), .o_o(o_o[7]));
  // the same dotted shapes in a cont_assign (must NOT move)
  logic [15:0] ca1, ca2;
  assign ca1 = q_i.addr[0 +: BankAddrW];
  assign ca2 = q_i.addr[WordW +: 16];
endmodule
