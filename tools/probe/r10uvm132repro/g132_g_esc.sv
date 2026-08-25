// r10uvm132 arm G — THE ESCAPED-IDENTIFIER FENCE, SLANG-ONLY.
//
// Surelog's preprocessor cannot carry `\name ` through a `\`-continued macro
// body: it reports `Syntax error: extraneous input '\'` three times and emits
// no database, so THIS ARM HAS NO GOLDEN and is scored by PRISTINE-vs-PATCHED
// dump identity alone (fence132.sh).  What it proves is the FIT fence: the
// bound symbol is `q$esc132` (8 characters) while the written token is
// `\q$esc132` (9), so the chain's component cannot reach the receiver span's
// start, `fit` reads 2 instead of 3, and the law declines — measured by the
// census instrument, and here by the dump being byte-identical.
`define G132_ESC_BODY \
  begin \
    int szg132 = 3; \
    while(\q$esc132 .size()<szg132) \q$esc132 .push_back(""); \
  end \

`define G132_ESC_QDA(TYPE) \
  begin \
    `G132_``TYPE``_BODY \
  end \

module top_g132;
  string \q$esc132 [$];
  initial begin
    `G132_ESC_QDA(ESC)
  end
endmodule
