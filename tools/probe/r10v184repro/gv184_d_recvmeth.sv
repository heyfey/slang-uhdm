// r10v184 VERIFIER ARM D — THE RECEIVER-KIND and METHOD-KIND axes of the law,
// inside a WILDCARD-IMPORT CLONE and at HOME.
//
// The implementer's arm B varied the receiver between a plain `string`, an
// associative array and a queue.  This arm reaches the faces neither arm A nor
// arm B touches:
//   * receiver is a string TYPEDEF, a STATIC string, a string declared inside a
//     BEGIN, a string ARRAY ELEMENT, a string QUEUE element
//   * the method varies: substr / getc / putc (TWO arguments, one a byte) /
//     compare (the argument is itself a STRING) / atoi + len (ZERO arguments)
//   * a CHAINED call whose receiver is another method call (the receiver is not
//     a name at all — the law must not fire)
//   * a USER-DEFINED method call on a class handle carrying a name argument
//     (the README says this is a different arm and golden binds it normally)
//   * an argument that is the RECEIVER'S OWN NAME
//   * a dynamic-array and a packed-vector receiver (built-in but NOT string)
// Names, numbers and orders are deliberately unlike the corpus' and unlike
// r10uvm184repro's own arms.
package Lattice305;

  typedef string strand_t;

  class Trellis305;
    int m_knot;
    string m_twine;
    function new(); m_knot = 4; m_twine = "twinework"; endfunction
    function int gird305(input int fml_g);
      return fml_g + m_knot;
    endfunction
  endclass

  function automatic string weave305(input int fml_w);
    strand_t      warp;               // string TYPEDEF receiver
    static string spool;              // STATIC string receiver
    string        skein[3];           // string ARRAY element receiver
    string        hank[$];            // string QUEUE element receiver
    string        other;
    byte          pip;
    int           gauge;
    int           dyn305[];
    bit    [15:0] band;
    Trellis305    frame;
    string        cloth;
    warp  = "warpthread";
    spool = "spoolthread";
    skein[0] = "skeinthread";
    hank.push_back("hankthread");
    other = "otherthread";
    pip   = 8'h41;
    gauge = 3;
    dyn305 = new[4];
    band  = 16'h00f0;
    frame = new();

    cloth = warp.substr(1, gauge);        // D1  TYPEDEF string receiver
    cloth = spool.substr(1, gauge);       // D2  STATIC string receiver
    cloth = skein[0].substr(1, gauge);    // D3  string ARRAY ELEMENT receiver
    cloth = hank[0].substr(1, gauge);     // D4  string QUEUE ELEMENT receiver
    cloth = frame.m_twine.substr(1, gauge); // D5 string CLASS-PROPERTY receiver
    warp.putc(gauge, pip);                // D6  putc: TWO name arguments
    cloth = warp.compare(other) ? "y" : "n";   // D7 argument is itself a STRING
    gauge = warp.len();                   // D8  ZERO-argument method
    gauge = warp.atoi();                  // D9  ZERO-argument method
    gauge = warp.getc(gauge);             // D10 argument is used elsewhere too
    cloth = warp.substr(1, warp.len());   // D11 argument is a nested CALL
    cloth = warp.substr(1, gauge).substr(0, 1); // D12 CHAINED — receiver is a call
    gauge = frame.gird305(gauge);         // D13 USER-DEFINED method, name argument
    gauge = dyn305.size();                // D14 dynamic array, zero args
    gauge = $countones(band);             // D15 system call, not a method
    return cloth;
  endfunction

endpackage

// WILDCARD import — the clone path the law owns.
package Bobbin305;
  import Lattice305::*;
  int seen_bobbin305 = 13;
  function automatic int use_bobbin305();
    return weave305(5).len();
  endfunction
endpackage

module top305;
  import Bobbin305::*;
  int tally305;
  initial begin
    tally305 = use_bobbin305();
    $display("%0d", tally305);
  end
endmodule
