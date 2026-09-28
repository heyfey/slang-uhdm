// § pkgFoldAtLeadingLeaf191 — v11u195 fresh: macro-born leaves from an included header in another root file
module top(output int o);
  assign o = p::M + p::N;
endmodule
