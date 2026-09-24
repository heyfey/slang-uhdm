// r10scr13 t4 (file A) — the CROSS-ROOT-FILE half of § connActualParamFold /
// § elabPortConnUnitEnumNet.  Scr1's `ifndef`-guarded headers expand in the
// FIRST file that includes them, so a later file's reference to a $unit enum
// member or localparam is a cross-file one.  Here file A holds the
// declarations and file B does the instantiating.
localparam bit [31:0] XP = 32'h21051400;
typedef enum logic [1:0] {
    XE0 = 2'b00,
    XE2 = 2'b10
} xe_t;

module a_dummy;
xe_t xsig;
endmodule
