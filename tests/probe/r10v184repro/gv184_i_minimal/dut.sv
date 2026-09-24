// r10v184 VERIFIER ARM I — the MINIMAL reproducer of the arm-G AWAY, so the
// official judge can be asked whether it SEES it.  One free package function
// whose built-in string method takes the function's OWN RETURN NAME as its
// argument, and one wildcard importer.  Nothing else.
package Cavetto705;
  function automatic int ogee705(input int fml_o);
    string bead;
    bead   = "beadmould";
    ogee705 = 2;
    ogee705 = bead.getc(ogee705);
    return ogee705 + fml_o;
  endfunction
endpackage

package Cyma705;
  import Cavetto705::*;
  int seen_cyma705 = 61;
  function automatic int use_cyma705();
    return ogee705(3);
  endfunction
endpackage

module top705;
  import Cyma705::*;
  int tally705;
  initial begin
    tally705 = use_cyma705();
    $display("%0d", tally705);
  end
endmodule
