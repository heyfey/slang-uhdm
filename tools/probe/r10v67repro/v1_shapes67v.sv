// r10v67 verifier arm 1 — DECLARED TYPE x RHS SHAPE, every spelling the law
// can meet, read as a bit-select INDEX one hop down in an ELAB gen-scope CA.
// Targets the shapes a2_types67.sv does NOT carry: hex/sized/based literals,
// a value from a MODULE parameter, from a PACKAGE parameter, from a FUNCTION
// call, a TYPEDEF'd type, a SIGNED negative value, a >32-bit value, byte /
// shortint / longint, a localparam of a parameterised width, and a
// localparam initialised from ANOTHER gen scope's localparam.
package v1pkg67;
  localparam int unsigned PW = 2;
  function automatic int unsigned pfv(input int unsigned a);
    return a + 1;
  endfunction
  typedef logic [4:0] idx_t;
endpackage

module v1_shapes67 #(parameter int unsigned MP = 3) (input logic [31:0] d,
                                                     output logic [31:0] y);
  import v1pkg67::*;
  logic [31:0] w;
  assign w = d;
  function automatic int unsigned lfv(input int unsigned a);
    return a + 2;
  endfunction

  for (genvar g = 0; g < 2; g++) begin : sA
    localparam int unsigned Khex   = 8'h05;          // HEX literal
    localparam int unsigned Ksz    = 6'd6;           // SIZED decimal
    localparam int unsigned Kbin   = 4'b0111;        // BINARY literal
    localparam int unsigned Koct   = 6'o10;          // OCTAL literal
    localparam int unsigned Kmp    = MP;             // from a MODULE parameter
    localparam int unsigned Kpkg   = PW;             // from a PACKAGE parameter
    localparam int unsigned Kcall  = pfv(3);         // from a PACKAGE call
    localparam int unsigned Klcall = lfv(3);         // from a LOCAL call
    localparam idx_t        Ktd    = 9;              // TYPEDEF'd type
    localparam int          Kneg   = -1 + 2;         // SIGNED arithmetic
    localparam longint unsigned Kbig = 64'd11;       // >32-bit declared type
    localparam byte         Kbyte  = 8'd12;          // byte
    localparam shortint     Kshort = 16'sd13;        // shortint
    localparam logic signed [7:0] Ksgn = -8'sd2 + 8'sd16; // SIGNED vector
    localparam int unsigned Kw     = $clog2(32);     // SYSTEM call init
    for (genvar h = 0; h < 1; h++) begin : sB
      logic r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14;
      assign r0  = w[Khex];
      assign r1  = w[Ksz];
      assign r2  = w[Kbin];
      assign r3  = w[Koct];
      assign r4  = w[Kmp];
      assign r5  = w[Kpkg];
      assign r6  = w[Kcall];
      assign r7  = w[Klcall];
      assign r8  = w[Ktd];
      assign r9  = w[Kneg];
      assign r10 = w[Kbig];
      assign r11 = w[Kbyte];
      assign r12 = w[Kshort];
      assign r13 = w[Ksgn];
      assign r14 = w[Kw];
      assign y[g] = r0^r1^r2^r3^r4^r5^r6^r7^r8^r9^r10^r11^r12^r13^r14;
    end
  end
  assign y[31:2] = '0;
endmodule
