// r10v186 (VERIFIER) ARM B — THE STATEMENT-POSITION AXIS of a dynamic-array
// `new[...]` in a WILDCARD-IMPORT CLONE.
//
// The lifted gate is a plain conjunct with no position test at all, while the
// SILENCERS it sits beside in the same OR — § controlBodyNoBind28 and the
// class-method silence — very much do have one.  A `new[...]` written inside
// an if body, a case item, a loop body, a fork arm or a named block therefore
// asks the OR a different question than the corpus' one, which is a `begin`
// body statement.  This arm reads one real Surelog golden at each position and
// at every block-naming shape, including the NAMED-BEGIN local that Surelog's
// `bindVariable` (CompileStmt.cpp:3089) has no `uhdmnamed_begin` case for.
//
// Names, numbers and orders deliberately unlike the corpus' and unlike
// r10uvm186's own arms.
package Baluster186v;

  function automatic int purlin186v(input int in_a);
    int dyn186v[];
    int flat186v;
    int hold186v;
    flat186v = in_a + 1;
    hold186v = 0;

    dyn186v = new[flat186v];              // P0  plain body statement (control)

    if (in_a > 0)
      dyn186v = new[flat186v];            // P1  an IF body
    else
      dyn186v = new[in_a];                // P2  an ELSE body

    if (in_a > 1) begin
      int ifloc186v;
      ifloc186v = 2;
      dyn186v = new[ifloc186v];           // P3  an IF body's own block local
    end

    case (in_a)
      0: dyn186v = new[flat186v];         // P4  a CASE item
      default: dyn186v = new[in_a];       // P5  a CASE default
    endcase

    for (int p6 = 0; p6 < 2; p6++)
      dyn186v = new[flat186v];            // P6  a FOR body

    while (hold186v < 1) begin
      dyn186v = new[flat186v];            // P7  a WHILE body
      hold186v = hold186v + 1;
    end

    do
      dyn186v = new[flat186v];            // P8  a DO-WHILE body
    while (0);

    repeat (1)
      dyn186v = new[flat186v];            // P9  a REPEAT body

    begin : lath186v
      int nblk186v;
      nblk186v = 3;
      dyn186v = new[nblk186v];            // P10 a NAMED-begin local
      dyn186v = new[flat186v];            // P11 the FUNCTION local, read from
                                          //     inside a NAMED begin
    end

    begin
      int ublk186v;
      ublk186v = 4;
      dyn186v = new[ublk186v];            // P12 an UNNAMED-begin local
      begin : rail186v
        int nin186v;
        nin186v = 5;
        dyn186v = new[nin186v];           // P13 NAMED inside UNNAMED
        dyn186v = new[ublk186v];          // P14 the UNNAMED parent's local
      end
    end

    begin : stile186v
      int outer186v;
      outer186v = 6;
      begin
        int inner186v;
        inner186v = 7;
        dyn186v = new[inner186v];         // P15 UNNAMED inside NAMED
        dyn186v = new[outer186v];         // P16 the NAMED parent's local
      end
    end

    return dyn186v.size();
  endfunction

  task automatic rung186v(input int in_b, output int out_c);
    int tdyn186v[];
    int tloc186v;
    tloc186v = in_b + 8;
    fork
      begin
        int fk186v;
        fk186v = 9;
        tdyn186v = new[fk186v];           // P17 a FORK arm's own local
      end
      tdyn186v = new[tloc186v];           // P18 a FORK arm, the task local
    join
    out_c = tdyn186v.size();
  endtask

endpackage

package Muntin186v;
  import Baluster186v::*;
  function automatic int use_muntin186v();
    return purlin186v(1);
  endfunction
  task automatic use_muntin_t186v(output int res186v);
    rung186v(2, res186v);
  endtask
endpackage

module top186vb;
  import Muntin186v::*;
  int score186v;
  int spin186v;
  initial begin
    use_muntin_t186v(spin186v);
    score186v = use_muntin186v() + spin186v;
    $display("%0d", score186v);
  end
endmodule
