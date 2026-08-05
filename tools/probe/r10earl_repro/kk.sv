// r10earl5 kk.sv — RESIDUE WITNESS, measured and NOT implemented (0 corpus
// tests at f5fbd25; found while decoding jj.sv's size-cast fold).
//
// A TYPE cast as a struct-pattern member value in a PACKAGE parameter:
//     parameter pwr_peri_t P = '{ wakeups: int'(1'b1), rstreqs: 2'b01 };
// golden's DEF listing folds it to
//     constant {ct=9 (UINT) sz=64 dec='' val='UINT:1'}
// and its TOP listing to
//     constant {ct=9        sz=16 dec='' val='UINT:1'}   (the MEMBER width)
// while our existing type-cast arm (ExprEmit, § FuncStructValSimple, measured
// on `bit'(CVA6ConfigCExtEn)`) writes BIN at the MEMBER width in the DEF view:
//     constant {ct=3 (BIN)  sz=16 dec='' val='BIN:0000000000000001'}
//
// So `bit'` and `int'` do NOT fold the same way and the existing arm cannot
// simply be widened — decode the distinguisher (target kind? 1-bit vs wider?)
// before touching it.  The SIZE-cast sibling (`16'(x)`, `WakeUpPeris'(x)`) IS
// implemented — see jj.sv, § patMemberSizeCastDef / § patMemberCastNoDecomp.
package kp;

  parameter HwRstReqs = 2;
  localparam WakeUpPeris = 16;

  typedef struct packed {
    logic [WakeUpPeris-1:0] wakeups;
    logic [HwRstReqs-1:0]   rstreqs;
  } pwr_peri_t;

  parameter pwr_peri_t PERI_TCAST = '{
    wakeups: int'(1'b1),
    rstreqs: 2'b01
  };

endpackage

module kchild (input logic clk_i, output logic o);
  kp::pwr_peri_t r0;
  assign r0 = kp::PERI_TCAST;
  assign o = r0.rstreqs[0] ^ clk_i;
endmodule

module kk (input logic clk_i, output logic o);
  kchild u_k (.clk_i(clk_i), .o(o));
endmodule
