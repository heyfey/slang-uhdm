// r10v160 cell z02 — a MODULE type parameter's default specialization.
// A module's default parameterization IS elaborated, so slang REPORTS the bad
// operand: a control that must stay SLANG_REJECT on BOTH binaries.
module topv160 #(type T=int);
  T t;
  string s;
  initial s = {"[", t.gt(), "]"};
endmodule
