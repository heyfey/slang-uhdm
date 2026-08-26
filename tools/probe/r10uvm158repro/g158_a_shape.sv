// r10uvm158 grid, arm A — BLOCK SHAPES x the bad-statement gate.
// Every `*Bad158` block holds ONE local of the class's type parameter and ONE
// statement slang REJECTS (`T::type_id::create` on the default `int`); every
// `*Ok158` twin is the SAME block shape with a statement slang ACCEPTS, and is
// the control that must not move.  MEASUREMENT ONLY.
package pa158;

  class shapeA158 #(type T = int);
    string sink158 = "";

    // (1) an IF-ARM begin with one local + one statement — the corpus shape.
    function string ifBad158();
      if (sink158 == "") begin
        T ib158;
        ib158 = T::type_id::create("ib158");
        sink158 = "ifBad";
      end
      return sink158;
    endfunction
    function string ifOk158();
      if (sink158 == "") begin
        T io158;
        io158 = 0;
        sink158 = "ifOk";
      end
      return sink158;
    endfunction

    // (2) a BARE inner begin.
    function void bareBad158();
      begin
        T bb158;
        bb158 = T::type_id::create("bb158");
        sink158 = "bareBad";
      end
    endfunction
    function void bareOk158();
      begin
        T bo158;
        bo158 = 0;
        sink158 = "bareOk";
      end
    endfunction

    // (3) a NAMED begin — the LABEL face.
    function void namedBad158();
      begin : lbBad158
        T nb158;
        nb158 = T::type_id::create("nb158");
        sink158 = "namedBad";
      end
    endfunction
    function void namedOk158();
      begin : lbOk158
        T no158;
        no158 = 0;
        sink158 = "namedOk";
      end
    endfunction

    // (4) a NESTED begin: the inner one is bad, the outer one is good.
    function void nestBad158();
      begin
        T outv158;
        outv158 = 0;
        begin
          T inv158;
          inv158 = T::type_id::create("inv158");
        end
      end
    endfunction

    // (5) a FOR-loop body.
    function void forBad158();
      for (int fi158 = 0; fi158 < 2; fi158++) begin
        T fb158;
        fb158 = T::type_id::create("fb158");
      end
    endfunction
    function void forOk158();
      for (int fj158 = 0; fj158 < 2; fj158++) begin
        T fo158;
        fo158 = 0;
      end
    endfunction

    // (6) a FORK arm.
    task forkBad158();
      fork
        begin
          T kb158;
          kb158 = T::type_id::create("kb158");
        end
      join_none
    endtask
    task forkOk158();
      fork
        begin
          T ko158;
          ko158 = 0;
        end
      join_none
    endtask

    // (7) a WHILE body and a CASE item.
    function void whileBad158();
      while (sink158 == "") begin
        T wb158;
        wb158 = T::type_id::create("wb158");
      end
    endfunction
    function void caseBad158();
      case (sink158)
        "a": begin
               T cb158;
               cb158 = T::type_id::create("cb158");
             end
        default: sink158 = "d";
      endcase
    endfunction
  endclass

endpackage

module topa158;
  initial begin
    $display("a158");
  end
endmodule
