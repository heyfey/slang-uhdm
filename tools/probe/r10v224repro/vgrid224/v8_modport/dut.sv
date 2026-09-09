// r10v224 adversarial arm — a MODPORT interface (the InterfaceModPort canary's
// shape) with the law's declarations in it.
package p224v8;
   typedef logic [1:0] tv8_t;
endpackage

interface if224v8();
   import p224v8::*;
   tv8_t v8_td224;
   tv8_t v8_ass224 [string];
   tv8_t v8_dyn224 [];
   logic v8_lg224;
   modport mp8_224 (input v8_td224, output v8_lg224);
endinterface

module top224v8;
   if224v8 u8_224();
endmodule
