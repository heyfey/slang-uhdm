// vbuvm19 adversarial grid G — ancestor chains that pass THROUGH a foreach.
package vgp19;
  class vbase19; int z19; endclass
  class vg19;
    vbase19 aa19[int];
    vbase19 bb19[int];
    extern function void innersame19();
    extern function void innerother19();
    extern function void twodeep19();
    extern task          reffrm19(ref vbase19 fq19[$]);
    extern function void disabled19();
  endclass

  // 1 — the OUTER foreach body assigns the SAME array the INNER one iterates
  function void vg19::innersame19();
    foreach (aa19[i]) begin
      aa19[i] = null;
      foreach (aa19[j]) $display("is", aa19[j]);
    end
  endfunction

  // 2 — the outer foreach body assigns the OTHER array
  function void vg19::innerother19();
    foreach (aa19[i]) begin
      bb19[i] = null;
      foreach (bb19[j]) $display("io", bb19[j]);
    end
  endfunction

  // 3 — three block levels between the foreach and the assignment
  function void vg19::twodeep19();
    begin : l1
      begin : l2
        begin : l3
          foreach (aa19[i]) $display("td", aa19[i]);
        end
      end
      aa19[1] = null;
    end
  endfunction

  // 4 — a TASK formal passed by ref, select assignment in the body
  task vg19::reffrm19(ref vbase19 fq19[$]);
    foreach (fq19[i]) $display("rf", fq19[i]);
    fq19[0] = null;
  endtask

  // 5 — a named block with a disable, assignment after it
  function void vg19::disabled19();
    begin : db19
      foreach (bb19[i]) begin
        if (bb19[i] == null) disable db19;
      end
      bb19[2] = null;
    end
  endfunction
endpackage
