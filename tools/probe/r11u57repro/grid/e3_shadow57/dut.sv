// r11u57 — THE IMPORT-SHADOW DOOR, ASKED OF THE BURIED CALL IN THE ELAB VIEW.
// § importedTypeShadowsTypeParam53 (r11v53): a wildcard-imported package type
// of the same bare name IS in Surelog's data type map, so `getTypespec`
// resolves and `compileBits` FOLDS even though SV binds the local parameter.
// The elaborated half must honour the same door.  Two names, one shadowed and
// one not, in the SAME module.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut
  import pk::*;
#(
    parameter type req_t = pk::req_t,   // SHADOWED by the wildcard import
    parameter type solo_t = logic [1:0] // no import exports this name
) (
    output logic o
);
  localparam int S1 = (1 << $bits(req_t));   // golden FOLDS (shadowed)
  localparam int S2 = (1 << $bits(solo_t));  // golden KEEPS
  assign o = ^{S1[0], S2[0]};
endmodule
