// r10uvm195 arm D — THE CONTROL.  The same declarations with NO wildcard
// import anywhere: nothing this pass owns may move in either binary.
package press195;
  class Sluice195;
    extern task quarry195(string chisel195="");
  endclass
  task Sluice195::quarry195(string chisel195="");
    int d_i195 = 3;
    process d_proc195;
    string d_s195;
    d_s195 = "x";
  endtask
  function void plain195();
    process d_p2195;
    string d_s2195;
    d_s2195 = "y";
  endfunction
endpackage
package loomless195;
  import press195::Sluice195;   // an EXPLICIT (non-wildcard) import
  class Bobbin195;
    function void anvil195();
      Sluice195 d_h195;
      d_h195 = null;
    endfunction
  endclass
endpackage
module top195;
  initial begin
    process d_mod195;
    string d_ms195;
    d_ms195 = "z";
  end
endmodule
