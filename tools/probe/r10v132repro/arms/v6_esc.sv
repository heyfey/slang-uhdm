`include "v_defs.svh"
// ESCAPED IDENTIFIER receiver reached as a macro ARGUMENT (slang-only fence;
// Surelog's preprocessor cannot carry `\name ` through a `\`-continued body).
module top_v6132;
  string \q$esc132 [$];
  string qplain132[$];
  initial begin
    `V_PASTE(QUEUE, \q$esc132 )
    `V_PASTE(QUEUE, qplain132)
  end
endmodule
