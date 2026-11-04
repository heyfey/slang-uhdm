// § memberEnumCloneKeepsBase147
package pb;
   typedef enum logic {
      BidirStd = 1'h1
   } pad_type_e;
   typedef struct packed {
      pad_type_e dio_pad_type;
   } target_cfg_t;
endpackage
module top(output logic o);
   import pb::*;
   parameter target_cfg_t TargetCfg = 1;
   assign o = '0;
endmodule
