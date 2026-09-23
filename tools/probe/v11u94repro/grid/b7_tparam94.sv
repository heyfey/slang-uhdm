// v11u94 break arms: type parameters, overrides, typed default patterns
package p97;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  localparam cfg_t DC = '{XLEN: 32'd32};
  typedef struct packed { logic [9:0] x; logic [2:0] y; } ts_t;
endpackage
module b7c #(parameter p97::cfg_t Cfg = p97::DC, parameter int W = 4,
             parameter type T = struct packed { logic [W-1:0] x; logic [Cfg.XLEN-1:0] y; })
           (input logic i, output logic o);
  localparam T TP = '{x: 1, y: 2};
  typedef struct packed { logic [Cfg.XLEN/2-1:0] h; } h_t;
  localparam h_t HD = h_t'{default: 1};
  localparam h_t HN = '{default: 1};
  assign o = i ^ TP.x[0] ^ HD.h[0] ^ HN.h[0];
endmodule
module b7 (input logic i, output logic o1, output logic o2, output logic o3);
  b7c u_a (.i(i), .o(o1));
  b7c #(.Cfg('{XLEN: 32'd16}), .W(6)) u_b (.i(i), .o(o2));
  b7c #(.T(p97::ts_t)) u_c (.i(i), .o(o3));
endmodule
