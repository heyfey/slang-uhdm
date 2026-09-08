// r10uvm204 arm E — THE MINIMISED CORPUS HEAD.  uvm-1.2
// `reg/uvm_reg_field.svh:1123-1140`, reduced to what the head needs and nothing
// else: an OUT-OF-BODY class method, a `case` item whose `begin` block declares
// the iterator, and a `for` loop whose INIT DECLARES the callback handle and
// whose SINGLE bare body statement calls a method THROUGH that handle.
// Cloned into the importing package by a wildcard import.
package quarryE204;
  typedef enum { PREDICT_WRITE204, PREDICT_READ204 } kindE204_e;
  class CbE204;
    virtual function void post_predictE204(int v204);
    endfunction
  endclass
  class CbIterE204;
    function CbE204 firstE204();
      return null;
    endfunction
    function CbE204 nextE204();
      return null;
    endfunction
  endclass

  class FieldE204;
    int mirroredE204;
    extern virtual function void do_predictE204(kindE204_e kindE204, int fvE204);
  endclass

  function void FieldE204::do_predictE204(kindE204_e kindE204, int fvE204);
    case (kindE204)
      PREDICT_WRITE204:
        begin
          CbIterE204 cbsE204 = new();
          this.mirroredE204 = 1;
          for (CbE204 cbE204 = cbsE204.firstE204(); cbE204 != null; cbE204 = cbsE204.nextE204())
            cbE204.post_predictE204(fvE204);
          fvE204 &= 3;
        end
      PREDICT_READ204:
        begin
          CbIterE204 cbsE204 = new();
          for (CbE204 cbE204 = cbsE204.firstE204(); cbE204 != null; cbE204 = cbsE204.nextE204())
            cbE204.post_predictE204(fvE204);
        end
    endcase
  endfunction
endpackage

package sluiceE204;                  // THE WILDCARD IMPORTER — the clone's home
  import quarryE204::*;
  class FlumeE204;
    function void raceE204();
      FieldE204 gateE204;
      gateE204 = null;
    endfunction
  endclass
endpackage

module topE204;
  import sluiceE204::*;
  initial begin
    FlumeE204 fE204;
    fE204 = new();
    fE204.raceE204();
  end
endmodule
