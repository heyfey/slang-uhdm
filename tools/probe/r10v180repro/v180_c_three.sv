// r10v180 arm C — ONE HOME, THREE IMPORTERS, and the home's own spelling as
// the control.  Two wildcard importers plus one explicit-named importer, each
// cloning the same two subroutines; plus a fourth package that spells the
// same typedef itself and imports nothing.
package Tundra_home;
  typedef logic [6:0] moss_lt;
  function automatic int unsigned moss_fn(moss_lt fen);
    moss_lt bog;
    bog = fen;
    if (bog[0]) begin
      moss_lt mire;
      mire = moss_lt'(bog + 1);
      begin
        moss_lt sedge;
        sedge = mire;
        bog = sedge;
      end
    end
    return int'(bog);
  endfunction
  task automatic moss_tk(input moss_lt fen, output int unsigned r);
    moss_lt bog;
    bog = fen;
    begin
      moss_lt heath;
      heath = moss_lt'(bog);
      r = int'(heath);
    end
  endtask
endpackage
package Tundra_w1;  import Tundra_home::*; endpackage
package Tundra_w2;  import Tundra_home::*; endpackage
package Tundra_n1;  import Tundra_home::moss_fn; endpackage
package Tundra_solo;
  typedef logic [6:0] moss_lt;
  function automatic int unsigned moss_fn(moss_lt fen);
    moss_lt bog;
    bog = fen;
    begin
      moss_lt mire;
      mire = moss_lt'(bog);
      bog = mire;
    end
    return int'(bog);
  endfunction
endpackage
module Tundra_top;
  import Tundra_home::*;
  moss_lt tarn;
  int unsigned r1, r2;
  initial begin
    tarn = 7'h2a;
    r1 = moss_fn(tarn);
    moss_tk(tarn, r2);
    r2 = r2 + Tundra_solo::moss_fn(tarn);
  end
endmodule
