// v125 arm V3 — argument SHAPES into a converting output formal, plus the
// SAME variable written by an output arg and READ on the very next line.
package Shape_Pkg;
  typedef logic [63:0] Bus64;
  typedef struct packed { logic [15:0] hi; logic [15:0] lo; } Pair16;

  function automatic int grab(output Bus64 dst); dst = 64'hAB; return 0; endfunction
  task automatic grabT(output Bus64 dst); dst = 64'hCD; endtask

  class Shape_User;
    logic [31:0] vec32;
    logic [31:0] mem [0:3];
    Pair16       pr;
    logic [31:0] whole [0:1];
    int          seen;
    task automatic go();
      logic [31:0] loc;
      logic [7:0]  byteArr [0:7];
      seen = grab(loc);            // bare local, converting
      seen = int'(loc);            // <-- the SAME variable read on the NEXT line
      seen = grab(vec32[7]);       // bit-select
      seen = grab(vec32[15:8]);    // part-select
      seen = grab(vec32[8 +: 4]);  // indexed part-select
      seen = grab(pr.hi);          // member chain
      seen = grab(mem[2]);         // array element
      seen = grab(mem[seen]);      // dynamic index
      seen = grab(byteArr[3]);     // unpacked element
      grabT(loc);                  // a TASK writing the same local
      seen = seen + int'(loc);     // read right after the task call
      seen = grab({vec32[3:0], vec32[7:4]}); // concatenation lvalue actual
    endtask
  endclass
endpackage
