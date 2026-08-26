// r10v157 ARM C — SCOPE FACES.  Nesting and statement flavours the
// implementer's a_scope/e_edge did not write, plus MULTIPLICITY (a generate
// loop, a twice-instantiated module, a parameterised class with TWO
// specialisations).  MEASUREMENT ONLY.
package Rookery157;
  class Perch157 #(type BEAK157 = int, int SPAN157 = 3);
    function int glide157();
      // subroutine body wrapper (SITE 2) inside a PARAMETERISED class
      typedef bit [SPAN157-1:0] featherSpan157;
      featherSpan157 down157;
      down157 = 0;
      return int'(down157);
    endfunction
    task roost157;
      fork
        begin : c_forkarm157
          // a typedef in a fork ARM nested inside a task body
          typedef bit [1:0] talon157;
          talon157 grip157;
          grip157 = 0;
        end
        begin
          // an UNNAMED sibling fork arm with its own typedef of ANOTHER name
          typedef logic [4:0] plume157;
          plume157 fan157;
          fan157 = 0;
        end
      join_none
    endtask
  endclass
endpackage

module Warren157 (input logic burrowClk157);
  import Rookery157::*;
  Perch157 #(int, 4) firstNest157;
  Perch157 #(bit, 7) secondNest157;

  always_ff @(posedge burrowClk157) begin : c_ff157
    typedef bit [13:0] tunnelWide157;
    tunnelWide157 dig157;
    dig157 <= 0;
  end

  initial begin : c_outer157
    typedef bit [2:0] outerHutch157;
    outerHutch157 outerHold157;
    begin : c_inner157
      // an INNER begin declaring a typedef of the SAME NAME as the outer one
      typedef bit [9:0] outerHutch157;
      outerHutch157 innerHold157;
      innerHold157 = 0;
    end
    outerHold157 = 0;
  end

  initial begin : c_dowhile157
    int spin157 = 0;
    do begin
      typedef bit [5:0] whirl157;
      whirl157 turn157;
      turn157 = 0;
      spin157++;
    end while (spin157 < 2);
  end

  initial begin : c_casedef157
    int pick157 = 1;
    case (pick157)
      0: begin
           typedef bit [1:0] shard157;
           shard157 chip157; chip157 = 0;
         end
      default: begin
           typedef bit [10:0] slab157;
           slab157 block157; block157 = 0;
         end
    endcase
  end

  for (genvar g157 = 0; g157 < 2; g157++) begin : c_gen157
    // a generate-loop body's own initial: TWO elaborated copies of one scope
    initial begin : c_genbody157
      typedef bit [7:0] cogTooth157;
      cogTooth157 spur157;
      spur157 = 0;
    end
  end
endmodule

module TopWarren157;
  logic clk157 = 0;
  // TWO instances of the same module: two elaborated copies of every scope
  Warren157 leftHole157 (.burrowClk157(clk157));
  Warren157 rightHole157 (.burrowClk157(clk157));
endmodule
