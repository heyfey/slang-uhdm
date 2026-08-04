// r10scr13 t3 — § connUnitParamSubst / § connUnitEnumImplicitNet.
// Scr1SvTests puts two $unit-scope names in instance CONNECTIONS and golden
// answers them OPPOSITELY:
//   scr1_tapc.sv:423  .din_parallel (SCR1_TAP_BLD_ID_VALUE)  -- a $unit
//     LOCALPARAM -- becomes the parameter's own constant at the USE SITE;
//   scr1_top_axi.sv:562 .core_width (SCR1_MEM_WIDTH_WORD)    -- a $unit ENUM
//     MEMBER -- stays a ref_obj whose actual is an IMPLICIT logic_net minted
//     at the use-site span (i.e. Surelog never resolved the name).
// Both headers are `include`d ABOVE the module, so both live in $unit.  This
// file separates $unit-vs-module home from localparam-vs-parameter-vs-enum.
localparam bit [31:0] UP    = 32'h21051400;   // $unit localparam, sized hex
localparam int        UI    = 7;              // $unit localparam, int
parameter  bit [3:0]  UPAR  = 4'ha;           // $unit parameter

typedef enum logic [1:0] {
    UE0 = 2'b00,
    UE2 = 2'b10
} ue_t;                                        // $unit enum

module sub (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic  [3:0] c,
    input logic  [1:0] d,
    input logic  [3:0] e,
    input logic  [1:0] f,
    input logic [31:0] g
);
endmodule

module top;
localparam bit [3:0] MP = 4'h5;                // MODULE localparam
parameter  bit [3:0] MQ = 4'h6;                // MODULE parameter
typedef enum logic [1:0] { ME2 = 2'b10 } me_t; // MODULE enum

sub i0 (
    .a (UP),        // $unit localparam, bare
    .b (UI),        // $unit localparam, int
    .c (UPAR),      // $unit parameter
    .d (UE2),       // $unit enum member
    .e (MP),        // module localparam
    .f (ME2),       // module enum member
    .g (UP + UI)    // $unit names inside an expression
);
endmodule
