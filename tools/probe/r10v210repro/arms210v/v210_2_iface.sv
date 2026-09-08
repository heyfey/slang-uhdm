// verifier arm 2 — INTERFACE parameter defaults (design->AllInterfaces, the
// `defif` listing kind the pass's census keys but its grid never built).
interface v2if;
  parameter I_LIT  = 5;
  parameter I_REF  = I_LIT;
  parameter I_EXPR = I_LIT + 1;
  localparam I_LOC = I_REF;
endinterface
module v2mod;
  v2if u();
endmodule
