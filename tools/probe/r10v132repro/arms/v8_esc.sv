// slang-only fence arm: an ESCAPED IDENTIFIER receiver written in a macro
// BODY, reached through a PASTED nested invocation.  Surelog cannot parse it,
// so this arm is scored by PRISTINE-vs-PATCHED dump identity only.
`define V8_ESC_RESIZE(ARG,VAL) \
  \q$esc132 .push_back(VAL); \
  sz8132 = \q$esc132 .size(); \

`define V8_PASTE(TYPE,ARG) \
  begin \
    `V8_``TYPE``_RESIZE(ARG,"") \
  end \

module top_v8132;
  string \q$esc132 [$];
  int sz8132;
  initial begin
    `V8_PASTE(ESC, unused132)
  end
endmodule
