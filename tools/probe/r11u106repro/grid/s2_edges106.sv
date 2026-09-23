// r11u106 grid S2: bound shapes (bare reads), package struct types, header
// parameters, overridden instances, interface and generate homes.
package q106;
  localparam int PW = 8;
  typedef struct packed { int unsigned XLEN; int unsigned W2; } cfg_t;
  localparam cfg_t DefCfg = '{XLEN: 32'd64, W2: 32'd8};
  typedef struct packed { logic [PW-1:0] a; logic [PW*2-1:0] b; } ps_t;
  localparam ps_t PKG_L = '{a: 1, b: 2};
  typedef struct packed { logic [PW-1:0] a; } hs_t;
endpackage
interface e2_if #(parameter q106::cfg_t Cfg = q106::DefCfg) ();
  typedef struct packed { logic [Cfg.XLEN-1:0] x; } it_t;
  localparam it_t IFL = '{x: 1};
  logic [3:0] sig;
endinterface
module e2_child #(parameter q106::hs_t HP = '{a: 3}, parameter int CW = 4) (input logic i, output logic o);
  typedef struct packed { logic [CW-1:0] x; } ct_t;
  localparam ct_t CL = '{x: 1};
  assign o = i ^ HP.a[0] ^ CL.x[0];
endmodule
module s2 #(parameter q106::cfg_t Cfg = q106::DefCfg, parameter int W = 16,
            parameter q106::hs_t HDR = '{a: 5})
           (input logic i, output logic o1, output logic o2, output logic o3);
  localparam int LW = W + 4;
  typedef struct packed { logic [W:0] x; } t21;
  localparam t21 c21_bareW = '{x: 1};
  typedef struct packed { logic [$clog2(W):0] x; } t22;
  localparam t22 c22_bareclog2 = '{x: 1};
  typedef struct packed { logic [LW-1:0] x; } t23;
  localparam t23 c23_localW = '{x: 1};
  localparam q106::ps_t c24_pkgstruct = '{a: 1, b: 2};
  typedef struct packed { logic [Cfg.XLEN*2-1:0] x; } t25;
  localparam t25 c25_wide = '{x: 1};
  typedef struct packed { logic [q106::PW-1:0] x; } t26;
  localparam t26 c26_pkgscoped = '{x: 1};
  typedef struct packed { logic [Cfg.XLEN-1:0] x; logic [W-1:0] y; logic [3:0] z; } t27;
  localparam t27 c27_threemem = '{x: 1, y: 2, z: 3};
  typedef struct packed { logic [0:Cfg.W2-1] x; } t28;
  localparam t28 c28_ascending = '{x: 1};
  e2_if #(.Cfg('{XLEN: 32'd16, W2: 32'd4})) u_if ();
  e2_child u_c1 (.i(i), .o(o1));
  e2_child #(.HP('{a: 7}), .CW(6)) u_c2 (.i(i), .o(o2));
  if (W > 1) begin : g_on
    typedef struct packed { logic [W-2:0] x; } gt_t;
    localparam gt_t GL = '{x: 1};
    assign o3 = GL.x[0] ^ c21_bareW.x[0];
  end
endmodule
