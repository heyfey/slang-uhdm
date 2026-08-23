// r10uvm115 / g115_d.sv — THE GENERATE-SCOPE ARM.  Purpose-built golden
// (Surelog is the reference).  The boundary gate found that r10uvm77's arm
// v77x4_scope.sv holds a `process` local inside a GENERATE block's `initial`
// and that golden RESOLVES it there (class_var + a NAMED class_typespec) while
// resolving nothing anywhere else — so this arm asks exactly where the line is:
// a plain module `initial`, a module task, a module function, a NAMED
// for-generate, a NAMED if-generate, an UNNAMED if-generate, a generate-block
// TASK, and a generate-block nested `begin`.
package d115;
  function void pfn();
    process pp;                       // control: package function  -> UNSUPPORTED
    pp = process::self();
  endfunction
endpackage

module top115d;
  int r;
  genvar g;

  // (1) a PLAIN module `initial` body local (no generate anywhere)
  initial begin
    process ip;
    ip = process::self();
  end

  // (2) a module TASK body local
  task mtsk();
    process tp;
    tp = process::self();
  endtask

  // (3) a module FUNCTION body local
  function int mfn();
    process fp;
    fp = process::self();
    return 0;
  endfunction

  // (4) a NAMED for-generate: `initial` body local  (the v77x4 shape)
  generate
    for (g = 0; g < 2; g++) begin : gblk
      int gr;
      initial begin
        process gp;
        gp = process::self();
        gr = int'(gp.status);
      end
      // (5) a generate-block TASK body local, and (5b) a NESTED `begin`
      //     inside that task — the block-item site reached from a gen-scope
      //     SUBROUTINE rather than from a gen-scope process.
      task gtsk();
        process gtp;
        gtp = process::self();
        begin
          process gtn;
          gtn = process::self();
        end
      endtask
      // (6) a generate-block nested `begin` inside `initial`
      initial begin
        begin
          process gnp;
          gnp = process::self();
        end
      end
    end
  endgenerate

  // (7) a NAMED if-generate
  generate
    if (1) begin : iblk
      initial begin
        process ifp;
        ifp = process::self();
      end
    end
  endgenerate

  // (8) an UNNAMED if-generate
  generate
    if (1) begin
      initial begin
        process unp;
        unp = process::self();
      end
    end
  endgenerate
endmodule
