// r10v224 adversarial arm — a TYPEDEF that HIDES the unpacked dimension.
// The declaration is a BARE NAME with no written dimension while its CANONICAL
// type is an unpacked array.  assocBuiltinIndexDim224 walks the canonical type,
// so an associative-typedef alias would be reprieved by a rule that was
// measured over WRITTEN dimensions.  MEASURED: slang-uhdm REJECTS a typedef
// whose target is an AssociativeArrayType or a DynamicArrayType ("unsupported
// constructs", rc=4, on the pristine binary too), so only the FIXED alias is
// reachable and it is kept here.
package p224v1;
   typedef logic [1:0] tv1_t;
endpackage

interface if224v1();
   import p224v1::*;
   typedef tv1_t fx1_t [2];
   fx1_t  v1_tdfix224;
   tv1_t  v1_wrass224 [string];
   tv1_t  v1_wrfix224 [2];
   tv1_t  v1_plain224;
endinterface

module m224v1();
   import p224v1::*;
   typedef tv1_t fx1m_t [2];
   fx1m_t v1_mtdfix224;
   tv1_t  v1_mwrass224 [string];
   tv1_t  v1_mplain224;
endmodule

module top224v1;
endmodule
