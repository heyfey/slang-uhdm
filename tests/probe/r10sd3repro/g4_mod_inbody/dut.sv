// g4 — MODULE-scope class, in-body method.  The home scope that is not a
// package: does golden name the module_inst, or nothing?
module top4;
  class c4;
    function bit f4(string kind);
      string loc;
      loc = kind;
      f4 = (loc == "HARD");
    endfunction
  endclass
  c4 h;
  initial h = new();
endmodule
