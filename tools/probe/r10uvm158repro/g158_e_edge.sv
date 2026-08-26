// r10uvm158 grid, arm E — EDGES.
// a rejected block inside a rejected block; the ELSE arm; a rejected block
// whose local is an unpacked ARRAY (the element-var / array_var pair); a
// NAMED fork; a rejected block whose bad statement is the LAST one and one
// where it is the FIRST; a rejected `do..while`; a rejected block holding a
// nested ACCEPTED block; two rejected siblings.  Every home is a generic
// class's default specialization (arm B's header says why).
package pe158;

  class payl158;
    static function payl158 mk158(string s); mk158 = new(); endfunction
  endclass

  class edgeE158 #(type T = int);
    string sink158 = "";

    // a rejected block nested inside a rejected block.
    function void dblBad158();
      begin
        T ea158;
        ea158 = T::mk158("ea158");
        begin
          T eb158;
          eb158 = T::mk158("eb158");
        end
      end
    endfunction

    // an ACCEPTED block nested inside a rejected one: the inner block keeps
    // its own binding, so only the OUTER one is recovered.
    function void mixBad158();
      begin
        T em158;
        em158 = T::mk158("em158");
        begin
          int en158;
          en158 = 5;
        end
      end
    endfunction

    // the ELSE arm.
    function void elseBad158();
      if (sink158 == "")
        sink158 = "x";
      else begin
        T ec158;
        ec158 = T::mk158("ec158");
      end
    endfunction

    // an unpacked-ARRAY local (element var + array_var pair) in a rejected
    // block, plus a QUEUE and an ASSOCIATIVE array.
    function void arrBad158();
      begin
        T ed158 [2];
        T eq158 [$];
        int ea2158 [string];
        int ee158;
        ee158 = T::mk158("ed158");
      end
    endfunction

    // a NAMED fork, rejected.
    task nfBad158();
      fork : nf158
        begin
          T ef158;
          ef158 = T::mk158("ef158");
        end
      join_none
    endtask

    // the bad statement FIRST vs LAST.
    function void firstBad158();
      begin
        T eg158;
        eg158 = T::mk158("eg158");
        sink158 = "g";
      end
    endfunction
    function void lastBad158();
      begin
        T eh158;
        sink158 = "h";
        eh158 = T::mk158("eh158");
      end
    endfunction

    // TWO rejected siblings in one body.
    function void twinBad158();
      begin
        T ei158;
        ei158 = T::mk158("ei158");
      end
      begin
        T ej158;
        ej158 = T::mk158("ej158");
      end
    endfunction

    // a rejected do..while body.
    task doBad158();
      do begin
        T ek158;
        ek158 = T::mk158("ek158");
      end while (sink158 == "");
    endtask
  endclass

endpackage

module tope158;
  initial begin
    $display("e158");
  end
endmodule
