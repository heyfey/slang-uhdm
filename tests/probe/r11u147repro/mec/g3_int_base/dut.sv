// § memberEnumCloneKeepsBase147
package pa;
   typedef enum int unsigned { A0 = 0, A1 = 5 } k_e;
endpackage
package pb;
   import pa::*;
   typedef struct packed { k_e k; logic [3:0] z; } s_t;
endpackage
module top(output logic [3:0] o);
   import pb::*;
   parameter s_t S = '0;
   assign o = '0;
endmodule
