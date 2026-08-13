// r10earl44 — the OVER-FIRE / UNDER-FIRE probe for the SCOPED port-connection
// law.  ONE module, so every cell shares a scope and the only thing that can
// separate two rows is the property the law claims to key on.
//
// The three hazards this file exists to catch:
//
//  (1) firing on the BARE form and destroying § defConnPkgParamFold43's cells
//      (`e1`/`e6` are its bare scalar and bare aggregate);
//  (2) firing on a CLASS scope, which § staticScopedRef12 already owns in
//      emitExpr — but a port connection SHORT-CIRCUITS emitExpr for a
//      NamedValue, so the class cells are measured here rather than assumed;
//  (3) firing on a scoped reference that is NOT a parameter at all (a package
//      variable, a package enum constant, a package function call).

package q44;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st44_t;
  typedef enum logic [1:0] { QE_A = 2'd0, QE_B = 2'd1 } en44_t;
  localparam logic [31:0] Q_PLAIN  = 32'h 00008000;
  localparam st44_t       Q_STRUCT = '{a: 8'h aa, b: 8'h bb};
  localparam int          Q_ARR [0:1] = '{3, 4};
  localparam en44_t       Q_ENUM   = QE_B;
  logic [31:0]            Q_VAR;
  function automatic logic [31:0] q_f(); return 32'h 5; endfunction
endpackage

class cls44;
  static const int         CI = 11;
  static int               SV = 12;
  localparam logic [31:0]  CP = 32'h 0000_00ff;
endclass

module sink44   (input logic [31:0] p_i);
endmodule
module sinkst44 (input q44::st44_t p_i);
endmodule
module sinkar44 (input int p_i [0:1]);
endmodule
module sinken44 (input q44::en44_t p_i);
endmodule

module mix44;
  import q44::*;
  // the module's OWN twin of Q_PLAIN: identical type, identical value
  localparam logic [31:0] E1_OWN = 32'h 00008000;

  sink44   u_e0 (.p_i (q44::Q_PLAIN));    // SCOPED pkg scalar   -> golden folds BARE
  sink44   u_e1 (.p_i (Q_PLAIN));         // BARE   pkg scalar   -> § 43, MUST NOT MOVE
  sink44   u_e2 (.p_i (E1_OWN));          // module's OWN param  -> ref_obj
  sinkst44 u_e3 (.p_i (q44::Q_STRUCT));   // SCOPED pkg struct   -> THE HEAD's shape
  sinkst44 u_e4 (.p_i (Q_STRUCT));        // BARE   pkg struct   -> ref_obj, MUST NOT MOVE
  sinkar44 u_e5 (.p_i (q44::Q_ARR));      // SCOPED pkg unpacked array
  sinkar44 u_e6 (.p_i (Q_ARR));           // BARE   pkg unpacked array
  sinken44 u_e7 (.p_i (q44::Q_ENUM));     // SCOPED pkg enum-TYPED param
  sinken44 u_e8 (.p_i (q44::QE_B));       // SCOPED pkg ENUM CONSTANT
  sink44   u_e9 (.p_i (q44::Q_VAR));      // SCOPED pkg VARIABLE
  sink44   u_e10 (.p_i (q44::q_f()));     // SCOPED pkg FUNCTION CALL
  sink44   u_e11 (.p_i (cls44::CI));      // CLASS-scoped static const (§ 12)
  sink44   u_e12 (.p_i (cls44::SV));      // CLASS-scoped static var   (§ 12)
  sink44   u_e13 (.p_i (cls44::CP));      // CLASS-scoped localparam   (§ 12)
endmodule
