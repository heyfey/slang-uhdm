// § spanCopyCarriesFile125
package up;
  typedef struct packed { logic [1:0] opc; logic [1:0] c; } opc_t;
  typedef struct packed { logic [3:0] rs; opc_t opcode; } fa_t;
  typedef struct packed { logic [3:0] imm; opc_t opcode; } fb_t;
  typedef union packed { fa_t a; fb_t b; } ins_t;
endpackage
module top import up::*; (input logic [7:0] ins, output logic [3:0] rs, imm);
  ins_t dec;
  assign dec = ins_t'(ins);
  assign rs = dec.a.rs;
  assign imm = dec.b.imm;
endmodule
