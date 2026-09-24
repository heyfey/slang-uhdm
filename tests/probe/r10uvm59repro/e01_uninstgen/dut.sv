// VERIFIER CELL e01 - the SECOND silent population: an UNINSTANTIATED generate
// block.  slang suppresses UnknownClassOrPackage when the scope is
// uninstantiated (Lookup.cpp:766), so a `::`-scoped reference there is a
// kind==Invalid with a scoped-name syntax and NO hard error - exactly the
// four-conjunct gate, outside a generic class.
module top59e01;
  int i;
  if (0) begin : gblk
    int j;
    initial begin
      j = nosuchpkg59::nosuchfn(1);
    end
  end
  initial begin
    i = 1;
  end
endmodule
