// r10v109repro/v109_b2n.sv - the NONBLOCKING `<= new` corner, ILLEGAL SV.
// Surelog rejects the file (PA0207).  Kept as the record that the predicate's
// NonblockingAssignmentExpression arm is unreachable on legal source.
package pkb2n;
  class Node2n;
    int w;
    function new(int a = 0); w = a; endfunction
  endclass
  class Kit2n;
    Node2n nbNewMu;
    extern task b2nset();
  endclass
  task Kit2n::b2nset();
    nbNewMu <= new();
  endtask
endpackage
