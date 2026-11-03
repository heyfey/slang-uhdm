// § specArgPairsImportedFormal468
// control: the scoreboard shape (a specialization as a class property) with no import
class item; int d; endclass
class C #(type T = item);
  typedef C #(T) this_type;
  T m;
endclass
class env;
  C #(item) comp;
endclass
module top;
  env e;
endmodule
