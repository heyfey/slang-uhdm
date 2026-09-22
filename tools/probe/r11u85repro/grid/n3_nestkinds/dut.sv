// r11u85 n3 -- LAW B: the nested member's own KIND.  Is the interface home's
// width the producer's int64 default, or the member's declared width?
package p;
  typedef struct packed {
    byte             b;
    logic [7:0]      l8;
    int              i;
    int unsigned     iu;
    longint unsigned lu;
    logic [11:0]     l12;
  } inner_t;
  typedef struct packed { inner_t q; logic [3:0] t; } outer_t;
  localparam outer_t OU = '{q: '{b: 8'sd5, l8: 8'hA5, i: 7, iu: 9,
                                 lu: 64'd70000, l12: 12'h123}, t: 4'h6};
endpackage

interface ifc #(parameter p::outer_t D = p::OU) ();
  logic [31:0] g_b;
  logic [31:0] g_l8;
  logic [31:0] g_i;
  logic [31:0] g_iu;
  logic [63:0] g_lu;
  logic [31:0] g_l12;
  assign g_b   = D.q.b;
  assign g_l8  = D.q.l8;
  assign g_i   = D.q.i;
  assign g_iu  = D.q.iu;
  assign g_lu  = D.q.lu;
  assign g_l12 = D.q.l12;
endinterface

module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.g_b ^ u_i.g_l8 ^ u_i.g_i ^ u_i.g_iu ^ u_i.g_lu[31:0] ^ u_i.g_l12;
endmodule
