// r10uvm161 arm C — THE OTHER POSITIONS.  Our emitter raises the
// § refVarLocalWindowBinds5 counter at SIX sites but clears
// `classMethodNoBind` at only THREE (unique/priority `if`, plain `if`, `case`
// condition).  This arm asks golden what the other three do for an ORDINARY
// (already-resolved) local of an IN-BODY class method — the population this
// pass moves — and what the block shapes around an assertion do.
//
// Every cell has its own name and its own number.  The `if` CONDITION cells are
// the calibrated control: our emitter is already right on them.
package pkgc161;

  typedef enum int { AMBER161 = 2, CINNABAR161 = 4 } hues161_e;

  class sites161;
    int tally161;

    function void reach161(int wharf161);
      int bollard161;
      hues161_e ochre161;
      event tocsin161;

      // ---- calibrated controls ----
      if (bollard161 == 101) tally161 = 102;             // if condition   -> window
      bollard161 = 103;                                   // assignment     -> bare

      // ---- CASE condition and CASE ITEM expression ----
      case (bollard161)                                   // case condition -> window
        104: tally161 = 105;
        default: tally161 = 106;
      endcase
      case (107)
        bollard161: tally161 = 108;                       // case ITEM expression
        default: tally161 = 109;
      endcase
      case (ochre161)
        AMBER161: tally161 = 110;
        default: tally161 = 111;
      endcase

      // (the EVENT CONTROL, the `wait` and the blocking `fork…join` pass time
      //  and belong in the TASK below — a function may not hold them, and an
      //  arm our own tool refuses is an arm that measures nothing)

      // ---- WHILE / FOR / DO-WHILE / REPEAT conditions (never windows) ----
      while (bollard161 < 113) bollard161 = 114;
      for (int k161 = 0; k161 < bollard161; k161++) tally161 = 115;
      do tally161 = 116; while (bollard161 < 117);
      repeat (bollard161) tally161 = 118;

      // ---- assertions in BLOCK SHAPES at depth 0 ----
      assert (bollard161 != 120);                         // plain body statement
      begin                                               // a plain (unnamed) begin
        assert (bollard161 != 121);
        assert (wharf161 != 122);
      end
      begin : tagged161                                   // a NAMED begin
        assert (bollard161 != 123);
      end
      fork                                                // a fork arm
        assert (bollard161 != 124);
      join_none
      // ---- assertions ONE control body deeper ----
      if (wharf161 == 126) begin
        assert (bollard161 != 127);
      end
      for (int j161 = 0; j161 < 2; j161++) begin
        assert (bollard161 != 128);
      end
      case (wharf161)
        129: assert (bollard161 != 130);
        default: assert (bollard161 != 131);
      endcase

      // ---- an assertion whose condition is a nested expression ----
      assert (((bollard161 + 1) * 2) != 132);
      assert (bollard161 inside {133, 134});
      assert (!(bollard161 == 135));
    endfunction

    // The TIME-PASSING half of the same question, in a TASK of the same
    // in-body class: the EVENT CONTROL expression, a `wait` condition and a
    // blocking `fork…join` arm.
    task reachtsk161(int quay161);
      int stanchion161;
      event carillon161;
      if (stanchion161 == 201) tally161 = 202;            // calibrated control
      @(carillon161) tally161 = 203;                      // event control expr
      wait (stanchion161 == 204);                         // wait condition
      assert (stanchion161 != 205);                       // assertion condition
      fork
        begin
          assert (quay161 != 206);
        end
      join
    endtask
  endclass

endpackage
