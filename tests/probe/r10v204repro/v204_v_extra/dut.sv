// r10v204 arm V — the remaining shapes a clone-body climb can meet: a loop
// whose body is a NAMED begin, a loop inside a FORK, a loop inside a class
// CONSTRUCTOR, a loop whose variable shadows a CLASS PROPERTY, and a loop
// inside a `while` body.
package quarryvv204;
  class Leafvv204;
    int orevv204;
    function void assayvv204(int v204);
    endfunction
  endclass
  class Itervv204;
    function Leafvv204 firstvv204();
      return null;
    endfunction
    function Leafvv204 nextvv204();
      return null;
    endfunction
  endclass

  class Aditvv204;
    int sinkvv204;
    Leafvv204 cPvv204;                 // a CLASS PROPERTY of a loop's name
    function new();
      Itervv204 itNvv204;
      itNvv204 = new();
      begin
        for (Leafvv204 cNvv204 = itNvv204.firstvv204(); cNvv204 != null; cNvv204 = itNvv204.nextvv204())
          cNvv204.assayvv204(1);
      end
    endfunction
    extern task minevv204(int selvv204);
  endclass

  task Aditvv204::minevv204(int selvv204);
    Itervv204 itvv204;
    int wvv204;
    itvv204 = new();
    wvv204 = 0;
    if (selvv204 == 1) begin
      // NAMED begin body.
      for (Leafvv204 cBvv204 = itvv204.firstvv204(); cBvv204 != null; cBvv204 = itvv204.nextvv204())
        begin : bodyvv204
          cBvv204.assayvv204(2);
        end
      // Shadowing a CLASS PROPERTY.
      for (Leafvv204 cPvv204 = itvv204.firstvv204(); cPvv204 != null; cPvv204 = itvv204.nextvv204())
        cPvv204.assayvv204(3);
      this.cPvv204 = null;
      // Inside a WHILE body.
      while (wvv204 < 2) begin
        for (Leafvv204 cWvv204 = itvv204.firstvv204(); cWvv204 != null; cWvv204 = itvv204.nextvv204())
          cWvv204.assayvv204(4);
        wvv204++;
      end
    end
    fork
      begin
        for (Leafvv204 cKvv204 = itvv204.firstvv204(); cKvv204 != null; cKvv204 = itvv204.nextvv204())
          cKvv204.assayvv204(5);
      end
    join
  endtask
endpackage

package sluicevv204;
  import quarryvv204::*;
  class Flumevv204;
    function void racevv204();
      Aditvv204 gatevv204;
      gatevv204 = null;
    endfunction
  endclass
endpackage

module topvv204;
  import sluicevv204::*;
  initial begin
    Flumevv204 f204;
    f204 = new();
    f204.racevv204();
  end
endmodule
