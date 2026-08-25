// r10v91 arm 4 — bind instances, procedural homes, function args, casts and
// the DEF/ELAB split for the r10earl91 law.
package p4;
  typedef logic [11:0] wa_t [2];
  typedef struct packed { logic [7:0] a; logic [3:0] b; } sm_t;
endpackage

module probe4 (input logic [11:0] d, output logic [11:0] o);
  logic [11:0] b1 [2];
  assign b1 = '{d, 12'd1};                 // inside a BIND instance
  p4::wa_t b2;
  assign b2 = '{d, 12'd1};                 // typedef'd, inside a bind (KEEP)
  assign o = b1[0]^b2[0];
endmodule

function automatic logic [11:0] f4 (input logic [11:0] a [2]);
  return a[0] ^ a[1];
endfunction

module core4 (input logic [11:0] din, output logic [11:0] q);
  logic [11:0] v12;
  assign v12 = din;

  // procedural assignment to an inline unpacked array
  logic [11:0] pr [2];
  always_comb pr = '{v12, din};

  // initial-block assignment
  logic [11:0] iv [2];
  initial iv = '{12'd4, 12'd5};

  // a declaration initialiser (var decl assign)
  logic [11:0] dv [2] = '{12'd6, 12'd7};

  // a localparam unpacked-array pattern (parameter-init producer, must not move)
  localparam logic [11:0] LP [2] = '{12'd8, 12'd9};

  // a function ARGUMENT pattern with an unpacked-array formal
  logic [11:0] fa;
  assign fa = f4('{v12, din});

  // a CAST to a typedef'd unpacked array
  p4::wa_t ca;
  assign ca = p4::wa_t'('{v12, din});

  // unsized-decimal first operand into an inline unpacked array
  logic [11:0] ud [2];
  assign ud = '{5, din};

  // sized-literal first operand
  logic [11:0] sl [2];
  assign sl = '{12'd5, din};

  assign q = pr[0]^iv[0]^dv[0]^LP[0]^fa^ca[0]^ud[0]^sl[0];
endmodule

module v4_bind91 (input logic [11:0] din, output logic [11:0] q);
  logic [11:0] c;
  core4 c0 (.din(din), .q(c));
  assign q = c;
endmodule

bind core4 probe4 pb (.d(din), .o());
