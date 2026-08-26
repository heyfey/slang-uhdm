// v158 arm J — FORK BLOCKS THAT OWN THEIR LOCALS (named and unnamed),
// plus a rejected block whose ONLY statement is a nested accepted block.
package Fpk;
  class rivet4;
    static function rivet4 set(string s); set = new(); endfunction
  endclass
  class Frk4 #(type XX = int);
    // UNNAMED fork owning a local, rejected
    task bareFork4();
      fork
        XX fa4;
        fa4 = XX::set("fa4");
      join
    endtask
    // NAMED fork owning a local, rejected
    task lblFork4();
      fork : tagA4
        XX fb4;
        fb4 = XX::set("fb4");
      join : tagA4
    endtask
    // NAMED fork owning a local, ACCEPTED (control)
    task okFork4();
      fork : tagB4
        int fc4;
        fc4 = 3;
      join : tagB4
    endtask
    // join_any / join_none with locals, rejected
    task anyFork4();
      fork : tagC4
        XX fd4;
        fd4 = XX::set("fd4");
      join_any : tagC4
    endtask
    task noneFork4();
      fork
        XX fe4;
        fe4 = XX::set("fe4");
      join_none
    endtask
    // rejected outer whose only statement is an ACCEPTED inner block
    function void shell4();
      if (1) begin
        XX ff4;
        begin
          int fg4;
          fg4 = 8;
        end
        ff4 = XX::set("ff4");
      end
    endfunction
  endclass
endpackage
module wtop_j;
  initial begin
    int hold4;
    hold4 = 0;
  end
endmodule
