// v11u79 q7 — QUALIFIERS AND LIFETIME.  r11u79 forces netShape26/netShape79
// TRUE for every SymbolKind::Net, and clones § 26's data_declaration reading
// into the array holder.  Does golden agree across const/var/static/automatic
// x struct typedef x unpacked array x net keyword?
package q7;
  typedef struct packed { int x; logic [7:0] y; } si_t;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } sl_t;
  si_t                 g_plain;
  const si_t           g_const   = '{x:0, y:0};
  var si_t             g_var;
  static si_t          g_static;
  sl_t                 g_slplain;
  var sl_t             g_slvar;
  const sl_t           g_slconst = '{a:0, b:0};
  logic [7:0]          g_arr [0:1];
  static logic [7:0]   g_arrstatic [0:1];
  const logic [7:0]    g_arrconst [0:1] = '{8'd0, 8'd0};
  var logic [7:0]      g_arrvar [0:1];
  si_t                 g_arrsi [0:1];
  wire si_t            g_wsi;
  wire sl_t            g_wsl;
endpackage

module dut (output logic [31:0] o);
  import q7::*;
  assign o = {16'd0, g_plain} ^ {16'd0, g_const} ^ {16'd0, g_var}
           ^ {16'd0, g_static} ^ {16'd0, g_slplain} ^ {16'd0, g_slvar}
           ^ {16'd0, g_slconst} ^ {24'd0, g_arr[0]} ^ {24'd0, g_arrstatic[0]}
           ^ {24'd0, g_arrconst[0]} ^ {24'd0, g_arrvar[0]} ^ {16'd0, g_arrsi[0]}
           ^ {16'd0, g_wsi} ^ {16'd0, g_wsl};
endmodule
