// r10uvm167 grid, arm C — THE HOMES, and the DEF/ELAB axis.
//
// The shell trigger of arms A and B lives in a GENERIC CLASS, because that is
// where the corpus's is.  It is NOT the only way to get one, and the law must
// not be secretly keyed on the class: this arm reproduces the SAME
// bad-expression shell in a MODULE, an INTERFACE, a PROGRAM and a PACKAGE-level
// function, using an argument that reads through an UNELABORATED GENERATE
// BLOCK's name — slang's other silent bad-bind — and, in the class homes, the
// type-parameter qualifier.
//
// Every home holds ONE call with trailing defaults, so a home that does not
// reach the law shows up as an unmoved cell rather than as an absence.
package cp167;
  class Sink167;
    function void ff167(string id, int a = 1, string b = "d");
    endfunction
    task tt167(int a, int b = 2);
    endtask
  endclass

  function automatic int cf167(int a, int b = 9);
    return a + b;
  endfunction

  // CLASS home (the corpus's own), both a static and an instance method
  class Chome167 #(type T167 = int);
    static function void c_stat(Sink167 s);
      s.ff167("A", T167::type_name);
    endfunction
    function void c_inst(Sink167 s);
      s.ff167("B", T167::type_name);
    endfunction
    task c_task(Sink167 s);
      s.tt167(T167::type_name);
    endtask
    function int c_bare();
      return cf167(T167::type_name);
    endfunction
    // the SAME calls with a bindable argument: the must-not-move controls
    static function void c_ok(Sink167 s);
      s.ff167("C", 3);
    endfunction
    task c_oktask(Sink167 s);
      s.tt167(4);
    endtask
  endclass
endpackage

// MODULE home.  `nosuch167::x` is a package that does not exist; inside an
// UNINSTANTIATED generate branch slang binds it bad and stays quiet, which is
// the same shell by a different road.
module cm167 #(parameter int P167 = 0) (input logic clk167);
  import cp167::*;
  Sink167 s167;
  int r167;
  if (P167 == 99) begin : dead167
    initial begin
      s167.ff167("M", nosuch167::val);      // shelled, 3 formals, 2 written
      s167.tt167(nosuch167::val);           // shelled task, 2 formals, 1 written
      r167 = cf167(nosuch167::val);         // shelled bare call
    end
  end
  initial begin
    s167.ff167("N", 7);                     // control, unshelled
    s167.tt167(8);
    r167 = cf167(5);
  end
endmodule

// INTERFACE home
interface ci167 #(parameter int Q167 = 0) ();
  import cp167::*;
  Sink167 si167;
  int ri167;
  if (Q167 == 98) begin : deadi167
    initial begin
      si167.ff167("I", nosuch167::val);
      ri167 = cf167(nosuch167::val);
    end
  end
  initial si167.ff167("J", 2);
endinterface

// PROGRAM home
program cg167 #(parameter int R167 = 0) ();
  import cp167::*;
  Sink167 sg167;
  if (R167 == 97) begin : deadg167
    initial sg167.ff167("G", nosuch167::val);
  end
  initial sg167.ff167("H", 6);
endprogram

module ctop167;
  logic clk167;
  cm167 #(.P167(0)) u_m167 (.clk167(clk167));
  ci167 #(.Q167(0)) u_i167 ();
endmodule
